function lmm = localmeanmag(mu_x, mu_y, sz) 
% LOCALMEANMAG  Compute the local mean of the magnitude given by vector
% matrices mu_x, mu_y.
%
% lmm = LOCALMEANMAG(mu_x,mu_y) will first compute the magnitude matrix
% implied by mu_x,mu_y, and then compute for each point the mean in each
% 3by3 pixel neighborhood (slightly modified for corners and edges)
% 
% lmm = LOCALMEANMAG(mu_x,mu_y,sz) uses the neighborhood sz as specified

    DEFAULT_SZ = 3;
    
    if nargin < 3
        sz = DEFAULT_SZ;
    end
    
    % get mags and ind
    mags = sqrt(mu_x.^2 + mu_y.^2);
    ind = double(mags > 0);
    
    lmm = localmean(mags, ind, sz);
    
    
end

