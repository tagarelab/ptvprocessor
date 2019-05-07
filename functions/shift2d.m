function shifted = shift2d(mat, vert, horz)
% SHIFT2D   Shift matrix horizontally and/or vertically
% shifted = shift2d(mat,vert,horz) where vert and horz are scalar values
% will shift the matrix down 'vert' entries and to the right 'horz'
% entries; negative values will shift up and to the left, correspondingly
% 
% not entering in a value of vert or horz will simply set that value as
% default to zero

    
    if nargin < 3
        horz = 0;
        if nargin <2
            vert = 0;
        end
        if nargin < 1
            error('not enough arguments');
        end
    end
    % first do a circular shift
    shifted = circshift(mat, [vert horz]);
    
    % pad zeros as necessary
    [nrows, ncols] = size(shifted);
    if vert > 0
        shifted(1:vert, :) = 0; 
    else
        shifted(nrows+vert+1:end, :) = 0; 
    end
    if horz > 0
        shifted(:, 1:horz) = 0; 
    else
        shifted(:, ncols+horz+1:end) = 0; 
    end
end

