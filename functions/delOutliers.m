function [X, V] = delOutliers(X, V, tileSize, dims)
% delOutliers   perform outlier deletion on specified image size (dims) using
% a mosaic of "outlier detection" tiles specified by tileSize.
%   [X, V] = delOutliers(X, V, sz, dims) performs outlier detection using
%   square tiles of length/width sz
%   [X, V] = delOutliers(X, V, [sz1 sz2], dims) performs outlier detection
%   using rectangles of width sz1 and height sz2
%    dims should be [nrows, ncols]
%    X assumed to be an array in format: frame# | col# | row#  
%    V assumed to be an array in format: xvel | yvel | xvar | yvar

    % grab inputs for tilesize
    if numel(tileSize) == 1
        tile_width = tileSize;
        tile_height = tileSize;
    else
        tile_width = tileSize(1);
        tile_height = tileSize(2);
    end
    % save inputs for dimension of image
    nrows = dims(1);
    ncols = dims(2);
    mosaic = true; % value set separately here for clarity in use of helper
                    % function
    % gets array specifiying the leftmost, rightmost, uppermost, and 
    % lowermost dimensions of every single tile to be used. will loop
    % through
    tileArray = getTileArray(nrows, ncols, tile_width, tile_height, mosaic);
    ntiles = size(tileArray, 1);
    
    for tileId = 1:ntiles
        % first grab dimensions specifying this current particular tiles
        tile = tileArray(tileId, :);
        left = tile(1); right = tile(2);
        upper = tile(3); lower = tile(4);
        % via design "matrix" X, get boolean array for each row of X,
        % specifying whether particular vector is inside current tile
        inTile = (X(:,3) <= lower & X(:,3) >= upper & ...
                    X(:,2) >= left & X(:,2) <= right);
        id = find(inTile); % get all rows corresponding to vectors in tile
        
        % get median velocity along each component for this tile
        medx = median(V(id, 1));
        medy = median(V(id, 2));
        
        % get the median deviation from median for this tile
        d = sqrt((V(id, 1) - medx).^2 + (V(id, 2) - medy).^2);     
        D = median(d);
        % we are computing notoutlierID and so we include velocities
        % outside of tile; we simply forgive it in the second line with ||
        allmedDist = sqrt((V(:, 1) - medx).^2 + (V(:, 2) - medy).^2);   
        notoutlierId = find(allmedDist <= 2*D | ~inTile);
        
        % keep only those not considered outliers inside this tile
        X = X(notoutlierId,:);
        V = V(notoutlierId,:);
    end
end

