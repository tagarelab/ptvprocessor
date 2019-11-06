function img_seq = tiff_read(fname)
% tiff_read     Read in tiff file to save as 3d matrix
% img_seq = tiff_read(fname) saves into img_seq the frames of a tiff or tif
% file. File must be 8-bit or it will throw an error. Uses imfinfo to read
% in filename for speed, which may cause errors on Unix
    info = imfinfo(fname);
    nframes = numel(info);
    frame = double(imread(fname, 1, 'Info', info)); % this method of reading
                                                    % is supposedly faster
    [nrows, ncols] = size(frame);
    img_seq = zeros(nrows, ncols, nframes);         
    for id = 1:nframes % now reading in every frame
        img_seq(:,:,id) = double(imread(fname, id, 'Info', info));
    end
end

