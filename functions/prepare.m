function [X, V, tracks, img] = prepare(tiff_fname, tracks_fname, npoints, ...
                                       tracker, min_npts, tile_size)
% PREPARE   Computes noisy, sparse velocity vectors from PTV track data. 
% Wrangles into acceptable format.
%
%   [X, V,  tracks, img] = PREPARE(tiff_fname, tracks_fname) prepares the
%   velocity vectors using as default 33 frames per partition for the
%   weighted linear fits and default tracker of TrackMate. The minimum
%   number of points required for a fit will be set equal to 33, ie,
%   smaller remainders of tracks will be discarded. No outlier detection is
%   performed.
%   X is returned as a two dimensional array in 3 columns in the format
%   frame | column | row | specifying the 3d location of the vector, and
%   correspondingly in the same row, V gives the velocity and variance data
%   in the formatx-velocity | y-velocity | x variance | y variance
%   tracks gives the track data as a table in the format 
%   track id | frame | col | row
%   img saves the tiff file as a 3d matrix, where the third dimension is
%   time
%
%   [X, V, ~, ~] = PREPARE(tiff_fname, tracks_fname, npoints, tracker)
%   saves as velocity vectors X, V, with npoints and tracker as specified
%   (either 'Mosaic' or 'TrackMate'). min_npts is set as default to be
%   equal to npoints, and no outlier detection is performed
%
%   [X, V, ~, ~] = PREPARE(tiff_fname, tracks_fname, npoints, tracker, ..
%   min_npts, tile_size) saves velocity vectors into X, V under format
%   specified above, now taking into account a user-specified min_npts (ie,
%   will only discard remainders of tracks smaller than min_npts) and a
%   specified tile_size for outlier detection using square tiles of
%   length tile_size
    
    DEFAULT_NPOINTS = 33;
    DEFAULT_TRACKER = 'TrackMate';
    % set some defaults
    if nargin < 3
        npoints = DEFAULT_NPOINTS;
    end
    if nargin < 4
        tracker = DEFAULT_TRACKER;
    end
    if nargin < 5 
        min_npts = npoints;
    end
    
    % reading in tracks. helper functions use Matlab-generated or prebuilt
    % functions, and wrangles the outputs into a standardized format
    fprintf('\n Reading in tracks.\n');
    if strcmp(tracker, 'TrackMate')
        tracks = process_TrackMate(tracks_fname);
    elseif (strcmp(tracker,'Mosaic') || strcmp(tracker,'ImageJ'))
        tracks = process_trajectories(tracks_fname);
    else 
        error('Tracker name not recognized.');
    end
    
    % converting tiff to img stack
    fprintf('\n Getting image from tiff-stack.\n');
    img = tiff_read(tiff_fname); % uses imfinfo, which exhibits odd behavior on Unix
    [nrows, ncols, ~] = size(img);
    fprintf('\n Performing linear fits on tracks.\n');
    % applies weighted least squares fit algorithm
    if nargin < 5
        [X,V] = weightedtracklinfit(tracks,npoints);
    else
        [X, V] = weightedtracklinfit(tracks, npoints, min_npts);
    end
    if nargin >= 6 % ie, if tile_size is provided
        fprintf('Removing outliers.\n');
        [X, V] = delOutliers(X, V, tile_size, [nrows ncols]);
    end
end

