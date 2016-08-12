classdef RandomWalk < strategy
    % set the private attributes here.
    properties (SetAccess = private)
        robots              % without an initial value
        controlGain = 5.5;  % with an initial value
    end
    
    methods
        % the constructor must always have this signature.
        % x, y, and z are the grid's terrain data.
        % they are automatically passed by the simulador.
        function this = RandomWalk(x, y, z)
            this@strategy(x, y, z);
        end
        
        % initializes the simulation.
        % @input robots: number of robots.
        % @input worldLimits: array comprising [xlimit, ylimit]
        % @return p: initial positions of all robots (Nx3 array)
        %         if the array is empty, positions will be randomized.
        % @return v: initial velocities of all robots (Nx3 array)
        %         if the array is empty, velocities will be set to zero.
        % @return enableDynamics: if set to true, inputs will be 
        %         interpreted as accelerations, otherwise as velocities. 
        function [p, v, enableDynamics] = initialize(this, robots, worldLimits)
            p = []; % lets the simulation randomize all positions.
            v = []; % lets the simulation initialize velocities to zero.
            enableDynamics = true; 
            this.robots = robots; % stores parameter in an attribute of the instance.
        end
        
        % control input of all robots.
        % @return input: control input (Nx3 array)
        function input = control(this, p, v)
            % random acceleration
            input = this.controlGain*(-1.0+2.0*rand(this.robots, 3));  
            
            % gets the height of every robot.
            h = this.getTerrainHeight(p(:, 1), p(:, 2));
            
            % defines the desired height as the 
            % maximum height of the terrain
            h = h + 0.3;
            
            % PD control on Z axis (naive height control).
            input(:, 3) = -1.5*(p(:, 3) - h) - 0.8*v(:, 3);
        end
    end
end