function j = ind2col(sz, ind)
% IND2COL   Get columm number of linear index for size.
% like ind2sub but specialized for second element. only works for two
% dimensions
    [~,j] = ind2sub(sz, ind);
end

