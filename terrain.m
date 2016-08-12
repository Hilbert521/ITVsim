% simple terrain generator by vgs/2014
% based on fractal brownian motion and perlin noise.

function [X, Y, Z] = terrain(n, lod, message)
    if nargin < 3
        message = 'LOD';
    end
    
    Z = zeros(n);
    [X, Y] = meshgrid(0:n-1);
    
    amp = 1; freq = 2;
    for i = (1:lod)
        wtb = waitbar(0, strcat(message, int2str(i)));
        AUX = perlin2d(n, freq);
        Z = Z + amp * AUX; freq = 2.0 * freq; amp = 0.5 * amp;
        close(wtb);
    end
end

% C-like implementation (slow in matlab)
function Z = perlin2d(n, grid) 
    %gradients
    U = (-1.0 + 2.0*rand(grid + 1));
    V = (-1.0 + 2.0*rand(grid + 1));
    
    %grid points
    Z = zeros(n);
    [X, Y] = meshgrid(linspace(0, grid-1, n));
    
    for i = (1:n)
        for j = (1:n)
            pi = floor(X(i,j)); pj = floor(Y(i,j));
            px = X(i,j) - pi; py = Y(i,j) - pj;
          
            d00 = dot([U(pi+1, pj+1), V(pi+1, pj+1)], [-px, -py]);
            d10 = dot([U(pi+2, pj+1), V(pi+2, pj+1)], [1.0-px, -py]);
            d11 = dot([U(pi+2, pj+2), V(pi+2, pj+2)], [1.0-px, 1.0-py]);
            d01 = dot([U(pi+1, pj+2), V(pi+1, pj+2)], [-px, 1.0-py]);
            
            px = smoothstep(px); py = smoothstep(py);
            Z(i, j) = mix(py, mix(px, d00, d10), mix(px, d01, d11));
        end
        waitbar(i/n);
    end
end

function c = mix(t, a, b)
    c = b*t + (1.0-t)*a;
end

function z = smoothstep(t)
    z = t*t*t*(t*(t*6.0 - 15.0) + 10.0);
end