function w = gaussianWeighting(n, sigma)
% GAUSSIANWEIGHTING     Get weights according approximately
% to a normalized Gaussian distribution
%   w = GAUSSIANWEIGHTING(n) outputs as w an array of length n,
%   approximately symmetric (depending on parity of n), roughly according
%   to a Gaussian distribution with standard deviation n/6. However, the
%   values are shifted down by a constant so that the minimum value
%   outputted is 0. Note that if n is even, then there will be slightly
%   more values outputted to the right of the bell peak; that is, w(n) = 0,
%   whereas w(1) will be a small value slightly greater than zero (but
%   still close to vanishing)
%   w = GAUSSIANWEIGHTING(n, sigma) outputs a set of weights according
%   roughly to a Gaussian distribution with standard deviation sigma,
%   shifted down so that the minimum value (occuring at both ends if n is
%   odd, occuring at the far right if n is even) is 0

    % set default sigma
    if nargin < 2
        sigma = n / 6;
    end
    % obtain (approximately) symmetric entry values into the Gaussian
    % function
    x = [floor(-(n/2)+1): floor(n/2)];
    
    % apply to filter and normalize
    filt = exp(-x.^2/(2*sigma^2));
    w = filt / sum(filt);
    % force vanishing at the ends
    minval = min(w);
    w = w - minval;
    w = w / sum(w); % renormalize after the fact
    w = w(:);
end

