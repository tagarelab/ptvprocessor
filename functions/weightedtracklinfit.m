function [X, V] = weightedtracklinfit(tracks, pLength, minPts)
% WEIGHTEDTRACKLINFIT   Fit sparse set of velocity vectors to tracks
%   [X, V] = WEIGHTEDTRACKLINFIT(tracks) will use weighted least squares
%   fit to compute velocity vectors for partitions of given tracks, using a
%   default partition size of 33 frames and a minimum number of points (ie,
%   will discard remainders of tracks smaller than this number) equal to
%   the default. The output X is a two-dimensional array specifying the 3d
%   (spatial dimension and time) location of velocity vectors in the format
%   frame# | col# | row#
%   whereas V is a two-dimensional array with rows corresponding to the
%   rows of X, specifying the component velocities and component variances
%   (from least squares fitting), given in the format
%   x-velocity | y-velocity | x-variance | y-variance
%
%   [X, V] = WEIGHTEDTRACKLINFIT(tracks, pLength) will make fits with given
%   partition size, setting minPts = pLength
%   [X, V] = WEIGHTEDTRACKLINFIT(tracks, pLength, minPts) will compute fits
%   with given partition size and given minPts size - ie, will discard
%   remainders if and only if there are fewer frames than minPts

    tic
    % set default number of points per partition
    DEFAULT_NTS = 33; 
    if nargin < 2
        pLength = DEFAULT_NTS;
    end
    if pLength < 3
        error('partition length must be at least three frames');
    end
    
    if nargin < 3
        minPts = pLength/2;
    end
    
    % manual setting - cannot be less than 3
    minPts = max(3, minPts);
    
    % pre-compute weights and time values; most partitions will use full
    % length
    weights = gaussianWeighting(pLength);
    L = floor((pLength-1)/2);
    tvals = [-L:L]';
    if numel(tvals) < pLength 
        tvals = [tvals;L+1]; % add one more value for even lengths
    end
    
    X = []; % design matrix in order: frame | col | row
    V = []; % output matrix in order: xvel | yvel | xvar | yvar
    
    ntracks = numel(unique(tracks(:,1)));
    progressbar('Performing weighted least squares fitting');
    for id = 1:ntracks
        if id == ntracks || rem(id,100) == 0
            progressbar(id/ntracks);
        end
        track = get_track(id, tracks);
        nframes = size(track, 1);

        if nframes < minPts
            continue % skip remainder of this track if too small
        end
        % continue while new start frame of partition is less than total
        % number of frames
        nPartitions = ceil(nframes / pLength);
        for iPartition = 1:nPartitions
            % get start and last frames of this partition
            start = (iPartition-1) * pLength + 1;
            last = min(iPartition * pLength, nframes);
            
            % get this current partition and associated info
            partition = track(start:last, :);
            xvals = partition(1:end, 2);
            yvals = partition(1:end, 3);
            currentPartitionSize = size(partition, 1);
            % if current size too small, skip.
            if currentPartitionSize < minPts
                continue;
            end
            
            % if smaller than typical, recompute weights and L, etc.
            if currentPartitionSize < pLength 
                tmpWeights = gaussianWeighting(currentPartitionSize);
                tmpL = floor((currentPartitionSize-1)/2);
                tmptvals = [-tmpL:tmpL]'; 
                if numel(tmptvals) < currentPartitionSize
                    tmptvals = [tmptvals; tmpL+1]; % for even values
                end
                [u,v,xvar,yvar] = weightedLeastSquaresFit(tmptvals,xvals,...
                                                        yvals,tmpWeights);
            else
                [u,v,xvar,yvar] = weightedLeastSquaresFit(tvals,xvals,...
                                                            yvals,weights);
            end
                      
            % save computed slopes
            x0 = u(1); 
            y0 = u(2);
            t0 = partition(L+1,1);
            
            xvel = v(1);
            yvel = v(2);
            
            X = [X; t0, x0, y0];
            V = [V; xvel, yvel, xvar, yvar];
        end
    end
    toc
end

