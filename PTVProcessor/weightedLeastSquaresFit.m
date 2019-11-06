function [u, v, xvar, yvar] = weightedLeastSquaresFit(tvals, xvals, ...
                                                            yvals, weights)
% WEIGHTEDLEASTSQUARESFIT   Get constant and slope of weighted least
% squares fit
% [u,v,xvar,yvar]=WEIGHTEDLEASTSQUARESFIT(tvals,xvals,yvals,weights) uses
% weights and given tvals as input to return constant value of fit in u and
% slope fit in v, both of which are two-dimensional vectors. u(1) and v(1)
% give position and slope of the x-component fit, whereas u(2) and v(2)
% give position and velocity of v

    % make sure inputs are the correct size
    assert(numel(tvals) == numel(xvals));
    assert(numel(tvals) == numel(yvals));
    if numel(weights) == 1
        weights = ones(size(tvals));
    end
    assert(numel(tvals) == numel(weights));
    pLength = numel(tvals);
    
    % prepare matrices, appending ones in tvals for constant term
    T = horzcat(ones([pLength,1]), tvals(:));
    X_segment = horzcat(xvals(:), yvals(:));
    W = diag(weights);
    % solution to weighted least squares fit
    K = (T'*W*T) \ (T'*W);
    b = K*X_segment;
    u = b(1,:);
    v = b(2,:);
    
    % compute fit and residuals for variance
    fitxvals = polyval([v(1) u(1)], tvals);
    fityvals = polyval([v(2) u(2)], tvals);
    
    residuals_x = fitxvals - xvals;
    residuals_y = fityvals - yvals;
    weighted_res_x = residuals_x' * W * residuals_x;
    weighted_res_y = residuals_y' * W * residuals_y;
    
    noisex = weighted_res_x;
    noisey = weighted_res_y;
    xvar = noisex*K*K';
    yvar = noisey*K*K';
    xvar = xvar(2,2);
    yvar = yvar(2,2);
            
end

