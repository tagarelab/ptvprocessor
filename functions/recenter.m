function arr = recenter(arr, n)
% RECENTER  Obtain the center n values of a given array
%   arr = recenter(arr, n) will return an array of length n that is take
%   from the center of the source array. If numel(arr) is even, and n is
%   odd, then the output array will be centered at numel(arr)/2 (that is,
%   slightly towards the left). If numel(arr) is odd, and n is even, output
%   arr will be symmetric about numel(arr)/2. If n > numel(arr), will
%   simply output arr back.

    if numel(arr) > n
        diff = numel(arr) - n;
        cut1 = floor(diff/2) + 1;
        cut2 = ceil(diff/2);
        arr = arr(cut1:end-cut2);
    end
end

