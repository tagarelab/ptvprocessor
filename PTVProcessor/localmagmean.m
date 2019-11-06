function lmm = localmagmean(mu_x, mu_y, sz)
% LOCALMAGMEAN  Get magnitude of the local mean
    
    ind = double(mu_x ~= 0 | mu_y~=0);
    lmpx = localmean(mu_x, ind, sz);
    lmpy = localmean(mu_y, ind, sz);
    
    lmm = sqrt(lmpx.^2 + lmpy.^2);
end

