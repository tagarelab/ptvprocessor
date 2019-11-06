function i = ind2row(sz, ind)
% IND2ROW   Get row number of linear index for size
% Like in2sub but specialized for the first element. only works for two
% dimensions
    [i,~] = ind2sub(sz, ind);
end

