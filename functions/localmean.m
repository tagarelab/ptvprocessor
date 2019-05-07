function lm = localmean(mu_x, ind, sz)
% LOCALMEAN     Compute for every point its local mean.
% lm = LOCALMEAN(mu_x,ind) will use indicator ind and matrix mu_x and a
% neighborhood of size 3 to compute the local mean. 
%
% lm = LOCALMEAN(mu_x) will use an indicator computed by a 1 at every
% element of mu_x for which there is a nonzero value, and 0 where mu_x is
% zero
%
% lm = LOCALMEAN(mu_x, ind, sz) will use a neighborhood as indicated by sz.
% If sz is even, then sz+1 will be used.
    % sz assumed to be odd, or else it will add one computes for every point in px the local mean
    % given by sz. if ind not given, then all zeros will be taken to be "no
    % observation"
    
    DEFAULT_SZ = 3;
    if nargin < 3
        sz = DEFAULT_SZ;
        if nargin < 2
            ind = double(mu_x~=0);
        end
    end
    % if sz is not odd, we will add 1
    if mod(sz,2) ~= 1
        sz = sz+1;
    end
    
    % initialize shifted volumes
    shiftMax = (sz-1)/2; 
    [nrows, ncols] = size(mu_x);
    mu_xVol = zeros([nrows, ncols, sz]);
    indVol = zeros([nrows, ncols, sz]);
    % for both ind and the actual values, create the shifted matrices as
    % necessary for adding. a local sum is therefore the sum of all shifted
    % matrices. this treats borders properly
    for vertShift = -shiftMax:shiftMax
        for horzShift = -shiftMax:shiftMax
            volId = sub2ind([sz, sz], vertShift+shiftMax+1,...
                                                horzShift+shiftMax+1);
            mu_xVol(:,:,volId) = shift2d(mu_x, vertShift, horzShift);
            indVol(:,:,volId) = shift2d(ind, vertShift, horzShift);
        end
    end
    localsum = sum(mu_xVol, 3);
    localind = sum(indVol, 3);
    
    temp = localind;
    temp(temp==0)=1; % in order to divide
    lm = localsum ./ temp;
end
