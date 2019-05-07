function tileArray = getTileArray(nrows, ncols, width, height, mosaic)
% getTileArray  Get array giving boundaries of tiles needed to cover
% specified image 
%   tileArray = getTileArray(nrows, ncols, width, height) returns an ntiles
%   by 4 array where each row specifies the leftmost index, right most
%   index, uppermost index (small), and bottom-most index of the tile,
%   tiled in a mosaic style, ie, corners of first set of tiles is covered
%   with each shared corner a new center of a tile. 
%   
%   tileArray = getTileArray(nrows, ncols, width, height, mosaic) returns
%   the array with tiling style specified by boolean value mosaic. If
%   false, will only place enough tiles so that image is covered, 
%   but will not place tiles on top of first set of tiles

    DEFAULT_STYLE = true;
    if nargin < 5
        mosaic = DEFAULT_STYLE;
    end
    
    % uses meshgrid to obtain leftmost, topmost corners
    [grid_y, grid_x] = meshgrid(1:height:nrows, 1:width:ncols);
    % uses number of such corners to compute total number of tiles that are
    % needed, initialize output tileArray
    ntiles = numel(grid_y);
    tileArray = zeros(ntiles, 4);
    
    % convert to one-dimensional array in the same way
    grid_y = grid_y(:); grid_x = grid_x(:);
    
    % begin loop through number of tiles to save into tileArray. This set
    % of loops will place tiles to (almost) cover the image
    for tileId = 1:ntiles
        upper = grid_y(tileId);
        left = grid_x(tileId);
        lower = min(upper + height - 1, nrows);
        right = min(left + width - 1, ncols);
        tileArray(tileId, 1) = left;
        tileArray(tileId, 2) = right;
        tileArray(tileId, 3) = upper;
        tileArray(tileId, 4) = lower;
    end
    % as long as mosaic was not set to false, move on to second loop
    % placing tiles at each relevant corner
    if mosaic
        % get the leftmost, uppermost corner of the second set of tiles -
        % after this getting the second set of tiles is equivalent to
        % obtaining a "covering set" of tiles on a rectangle starting at
        % those values
        initVert = round(height/2); initHorz = round(width/2);
        % get upper left corners using an identical method
        [mosaic_y, mosaic_x] = meshgrid(initVert:height:nrows-initVert, initHorz:width:ncols-initHorz);
        % with analagous coding, we initialize a mosaicTileArray and get
        % tiles into this set, and then loop through the left corners to
        % save into the empty array
        mtiles = numel(mosaic_y);
        mosaicTileArray = zeros(mtiles, 4);
        mosaic_y = mosaic_y(:); mosaic_x = mosaic_x(:);
        
        for tileId = 1:mtiles
            upper = mosaic_y(tileId);
            left = mosaic_x(tileId);
            lower = min(upper + height - 1, nrows);
            right = min(left + width - 1, ncols);
            mosaicTileArray(tileId, 1) = left;
            mosaicTileArray(tileId, 2) = right;
            mosaicTileArray(tileId, 3) = upper;
            mosaicTileArray(tileId, 4) = lower;
        end
    end
    tileArray = [tileArray; mosaicTileArray];
    
end

