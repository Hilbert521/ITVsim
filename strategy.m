classdef strategy < handle
    % should this be protected?
    properties (SetAccess = private)
        XT, YT            % X and Y coors of terrain.
        ZT, dZTdX, dZTdY  % Z coords of terrain and 
        dZT2dX2, dZT2dY2  % its first and second deritvative.
    end
    
    methods
        % terrain's X Y Z data.
        function this = strategy(x, y, z)
            this.XT = x; this.YT = y; this.ZT = z;
            this.dZTdX = diff(z, 1, 1); this.dZTdY = diff(z, 1, 2);
            this.dZT2dX2 = diff(z, 2, 1); this.dZT2dY2 = diff(z, 2, 2);
        end
        
        function z = getTerrainHeight(this, x, y)
            z = interp2(this.XT, this.YT, this.ZT, x, y);
        end
        
        %function z = getTerrainInclination(this, x, y)
        %    z = interp2(this.XT, this.YT, this.ZT, x, y);
        %end
    end
end