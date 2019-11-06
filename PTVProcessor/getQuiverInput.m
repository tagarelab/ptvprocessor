function [x, y, xvals, yvals] = getQuiverInput(vx, vy, sparsity)
% GETQUIVERINPUT    Obtain input for quiver function, with choise of
% sparsity
% [x,y,xvals,yvals] = GETQUIVERINPUT(vx,vy,sparsity) returns the coordinate
% locations as separate column vectors: x,y with corresponding column
% vector of values xvals, yvals, from matrices vx, vy, and given sparsity
    assert(isequal(size(vx),size(vy)));
    [nrows, ncols] = size(vx);
    [x,y] = meshgrid(1:sparsity:ncols, 1:sparsity:nrows);
    % note that x and y are matrices, where each row of x is identical, and
    % each column of y is identical.
    % since matrix subsetting using two distinct columns is ENTRY-WISE, we
    % only need to enter in a single row and a single column, and all
    % necessary values of the 2d subset will be returned as output
    row_x = x(1,:)';
    col_y = y(:,1);
    xvals = vx(col_y, row_x);
    yvals = vy(col_y, row_x);

end