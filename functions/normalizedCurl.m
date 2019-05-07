function vorticity = normalizedCurl(mu_x, mu_y, localsz)
% NORMALIZEDCURL    Compute a locally normalized curl. Uses Matlab's curl
% function and normalizes by dividing by the local mean of the magnitude.
% vorticity = NORMALIZEDCURL(mu_x,mu_y) will return a 2d matrix with
% the same size as the inputs where each point is the mean of the magnitude
% of its immediate neighbors (and itself). That is, local is taken to mean
% a 3 by 3 pixel neighborhood, and magnitude is sqrt(mu_x.^2+mu_y.^2)
% vorticity = NORMALIZEDCURL(mu_x,mu_y,localsz) computes vorticity for the
% desired definition of local as specified by localsz (assumed to be a
% square)

    % CURRENTLY DOES NOT ACTUALLY WORK WITH LOCALSZ AND SIMPLY USES 3 BY 3
    % SQUARES
    DEFAULTSZ = 3;
    if nargin < 3
        localsz = DEFAULTSZ;
    end
    % first compute the curl
    [cz, ~] = curl(mu_x, mu_y);
    % get local mean mag
    lmm = localmeanmag(mu_x, mu_y, localsz);
    
 
    % compute normalized curl, ie, vorticity
    vorticity = cz ./ lmm;
    % nans are allowed to get a dark blue outside where fluid region is not
    % segmented
end

