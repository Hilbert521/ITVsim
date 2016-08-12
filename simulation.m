function simulation(handles)
    robots = round(get(handles.robotsSlider, 'Value'));
    
    X  = get(handles.terrain, 'XData');
    Y  = get(handles.terrain, 'YData');
    ZT = get(handles.terrain, 'ZData');   % terrain data
    ZA = get(handles.anomalies, 'CData') - 64; % anomalies data
    ZAmin = min(ZA(:)); ZAmax = max(ZA(:));
    
    % world limits
    limits = [max(X(:)) max(Y(:))];
    
    % loads the control algorithm.
    algorithmArray = cellstr(get(handles.algorithmPopup, 'String'));
    algorithm = algorithmArray{get(handles.algorithmPopup, 'Value')};
    [~, algorithm, ~] = fileparts(fullfile(pwd, algorithm));
    algorithm = eval(strcat(algorithm, '(X, Y, ZT)'));
    [q, v, enableDynamics] = algorithm.initialize(robots, limits);
    
    if length(q) == 0
        % randomize positions and get terrain height
        q = zeros(robots, 3);        
        q(:,1:2) = rand(robots, 2).*repmat(limits, robots, 1);
        q(:, 3) = interp2(X, Y, ZT, q(:, 1), q(:, 2)) + 0.01; 
    end
    if length(v) == 0
        v = zeros(robots, 3);
    end
    lastq = q;
    
    % setup handle for plotting robots.
    if isfield(handles, 'robots') && ishandle(handles.robots)
        delete(handles.robots); 
    end
    axes(handles.renderer);
    handles.robots = plot3(q(:, 1), q(:, 2), q(:,3), 'ok');
    set(handles.robots, 'MarkerFaceColor', 'r');
    set(handles.robots, 'MarkerSize', 12);
    
    % setup handles for the anomaly map of each robot.
    ZR = cell(robots, 1);
    for i = (1:robots)
        ZR(i) = {zeros(limits(1)+1, limits(2)+1)};
    end
    
    % simulation with fixed timestep and variable render time.
    dt = get(handles.timestepSlider, 'Value');
    acc = 0.0; tic;
    while ishandle(handles.renderer) && strcmp(get(handles.stopBtn, 'Enable'), 'on')
        
         % accumulate render time and avoid physics spiralling.
        acc = min(acc + toc, 0.25); tic;
        
        % integrate physics until renderer is caught up.
        while acc >= dt
            lastq = q; acc = acc - dt;
            
            % sense anomalies (this is slow as hell in matlab).
            for i = (1:robots)
                kernel = exp(-0.1*((X-q(i,1)).^2 + (Y-q(i,2)).^2));
                %kernel = (X-q(i,1)).^2 + (Y-q(i,2)).^2;
                %kernel = kernel < (limits(1)/4)^2;
                ZR(i) = {ZA.*kernel + (1.0-kernel).*cell2mat(ZR(i))};
            end
            
            % control equation
            input = algorithm.control(q, v);
                        
            % simple taylor expansion for the integral (TODO: runge-kutta).
            if enableDynamics
                q = q + v*dt + 0.5*dt*dt*input;
                v = v + input*dt;
            else
                q = q + input*dt;
            end
            
            % fold the terrain onto a sphere (TODO: is this needed?)
            q(:,1:2) = mod(q(:,1:2), repmat(limits, robots, 1));
        end
        
        % interpolate lastq and q based on accumulated time.
        % this smooths the movement in the renderer for high-speed PCs.
        alpha = acc/dt; frameq = alpha*q + (1.0 - alpha)*lastq;
        set(handles.robots, 'XData', frameq(:, 1), ...
                            'YData', frameq(:, 2), 'ZData', frameq(:, 3));
        
        % plot the current anomaly map in the anomalyRenderer.
        currentmap = round(get(handles.anomalyMapSlider, 'Value'));
        if (currentmap == 0)
            set(handles.currentAnomalyText, 'String', 'Terrain');
            set(handles.anomaliesTop, 'CData', ... 
            ZA + handles.colormapLength);
        else
            set(handles.currentAnomalyText, 'String', ...
                strcat('Robot ', int2str(currentmap)));
            set(handles.anomaliesTop, 'CData', ... 
                cell2mat(ZR(currentmap)) + handles.colormapLength);
        end
        
        drawnow;
    end
    
    guidata(handles.simulateBtn, handles);
end