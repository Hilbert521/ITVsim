% This is a demo based on the paper: Segregation of Multiple Heterogeneous 
% Agents in a Robotic Swarm (ICRA 2014). Please refer to RandomWalk.m or  
% the user's manual for a descriptive tutorial on how to code a strategy.

classdef Segregation < strategy
  
    properties (SetAccess = private)
        robots          % number of robots
        const           % constants matrix
        groups = 3;     % number of groups.
        samples
        error  = false; 
    end
    
    methods
        function this = Segregation(x, y, z)
            this@strategy(x, y, z);
            this.samples = size(z);
        end
       
        function [p, v, enableDynamics] = initialize(this, robots, ~)
            p = []; v = []; enableDynamics = true; 
            this.robots = robots;
     
            if mod(this.robots, this.groups) ~= 0
                uiwait(msgbox('This demo requires that the number of robots be a multiple of 3!', 'Error', 'modal'));
                this.error = true;
                return;
            end
            
            dAA = 0.1*this.samples(1); dAB = 0.3*this.samples(1);
            [i, j] = meshgrid((1:this.robots));
            gpr = this.groups / this.robots;
            AA  = (floor(gpr*(i-1)) == floor(gpr*(j-1)));
            AB  = (floor(gpr*(i-1)) ~= floor(gpr*(j-1)));
            this.const = dAA .* AA + dAB .* AB;
        end
        
        % control input of all robots.
        % @return input: control input (Nx3 array)
        function input = control(this, p, v)
            input = zeros(this.robots, 3);
            if (this.error) 
                return; 
            end
            
            % Relative position among all pairs [q(j:2) - q(i:2)].
            xij  = bsxfun(@minus, p(:,1)', p(:,1));
            yij  = bsxfun(@minus, p(:,2)', p(:,2));
    
            % Relative velocity among all pairs [v(j:2) - v(i:2)]..
            vxij = bsxfun(@minus, v(:,1)', v(:,1));
            vyij = bsxfun(@minus, v(:,2)', v(:,2));
    
            % Relative distance among all pairs.
            dsqr = xij.^2 + yij.^2;
            dist = sqrt(dsqr);
       
            % Control equation.
            dV = dist - this.const + 1.0 ./ dist - this.const ./ dsqr;
            ax = - dV .* xij ./ dist - vxij;
            ay = - dV .* yij ./ dist - vyij;
    
            % This gets rid of NaN because of division by zero.
            ax(1:this.robots+1:end) = 0;
            ay(1:this.robots+1:end) = 0;
      
            % a(i, :) -> acceleration input for robot i.
            input(:, 1) = sum(ax)'; input(:, 2) = sum(ay)';
            
            % naive height control.
            h = this.getTerrainHeight(p(:, 1), p(:, 2)) + 0.3;
            input(:, 3) = -1.5*(p(:, 3) - h) - 0.8*v(:, 3);
        end
    end
end