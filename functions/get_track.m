function track_info = get_track(track_id, track_mat)
% GET_TRACK     Get data of a particular track using trackId 
%   track_info = get_track(track_id, track_mat) where track_mat is an array
%   in four columns, retrieves the rows of track data where track_id (first
%   column) is as given. The output is in the form
%   frame# | col# | row#
    index = find(track_mat(:,1) == track_id);
    track_info = track_mat(index, 2:4);
end