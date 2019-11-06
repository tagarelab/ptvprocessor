function segrows = segTable(X, seg)
% SEGTABLE      Get list of rows inside matrix segmentation given a design
% matrix table. 
% segrows = SEGTABLE(X,seg) returns row ids of all rows of design vector
% table X, assumed to be in the format col# | row# that are inside
% segmentation seg, assumed to be desired target image size.
[nrows, ncols] = size(seg);
id = sub2ind([nrows, ncols], round(X(:,2)), round(X(:,1)));
isIncluded = seg(id);
segrows = find(isIncluded == 1);
end

