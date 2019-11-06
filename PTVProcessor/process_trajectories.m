function tracks = process_trajectories(tracks_fname) 
% process_trajectories   Wrangle Mosaic trajectories output .csv file into 
% a table
%   tracks = process_trajectories(fname) returns as output the result of
%   wrangling the given .csv file into a table in the format 
%   trackId | frame# | col# | row# 
    tracks_table = importTrajectories(tracks_fname, 2, inf);
    track_data = table2array(tracks_table);
    track_data(:,3:5) = track_data(:,3:5) + 1; % because it is zero indexed
    tracks = track_data(:,2:5);
end

