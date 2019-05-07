
function tracks = process_TrackMate(fname) 
% process_TrackMate   Wrangle TrackMate output .xml file into a table
%   tracks = process_TrackMate(fname) returns as output the result of
%   wrangling the given .xml file into a table in the format 
%   trackId | frame# | col# | row# 
    tic
    [track_data, ~] = importTrackMateTracks(fname);
    toc
    tracks = [];
    tic
    fprintf('\n Wrangling track data... \n');
    progressbar('Wrangling track data')
    ntracks = length(track_data);
    for track_id = 1:ntracks
        if track_id == ntracks || rem(track_id,100) ==0
            progressbar(track_id/ntracks);
        end
        track = get_track_info(track_id, track_data); 
        track = track + 1; % because TrackMate indexes at zero
        track(:,2:4) = track;
        track(:,1) = track_id;
        tracks = [tracks; track];    
    end
    toc
end

function track_info = get_track_info(track_num, track_data)%, window)
    % given track number in track_data tracks (from track_mate)
    % and window of frames, retrieves track info in the order:
    % frame | x | y
    % NOTE: TRACKMATE INDEXES AT 0
    traj = track_data(track_num); traj = traj{1};
    track_info = traj(:, 1:3);
end

