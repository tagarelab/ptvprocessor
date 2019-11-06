function varargout = PTVProcessor(varargin)
% PTVPROCESSOR MATLAB code for PTVProcessor.fig
%      PTVPROCESSOR, by itself, creates a new PTVPROCESSOR or raises the existing
%      singleton*.
%
%      H = PTVPROCESSOR returns the handle to a new PTVPROCESSOR or the handle to
%      the existing singleton*.
%
%      PTVPROCESSOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PTVPROCESSOR.M with the given input arguments.
%
%      PTVPROCESSOR('Property','Value',...) creates a new PTVPROCESSOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PTVProcessor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PTVProcessor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose 'GUI allows only one
%      instance to run (singleton)'.
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PTVProcessor

% Last Modified by GUIDE v2.5 01-Apr-2019 13:48:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PTVProcessor_OpeningFcn, ...
                   'gui_OutputFcn',  @PTVProcessor_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before PTVProcessor is made visible.
function PTVProcessor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PTVProcessor (see VARARGIN)

% Choose default command line output for PTVProcessor
handles.output = hObject;

% Update handles structure
handles.Tracker = 'TrackMate';
handles.tiffFile = '';
handles.trackFile = '';
handles.mu_x = 0;
handles.mu_y = 0;
handles.mu_xsd = 0;
handles.mu_ysd = 0;
handles.seg = 0;
handles.hasSegmentation = false;
handles.img = 0;
handles.tracks = 0;
handles.hasTracks = false;
handles.isProcessed = false; % mu_x, mu_y, mu_xsd, mu_ysd
handles.partitionSize = 33;
handles.minPts = 33;
handles.outlierDetectionTileSize = 35;
handles.regressionApproxMethod = 'sd';

guidata(hObject, handles);

% UIWAIT makes PTVProcessor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PTVProcessor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in tracker_popup.
function tracker_popup_Callback(hObject, eventdata, handles)
% hObject    handle to tracker_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tracker_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tracker_popup
switch get(handles.tracker_popup, 'Value')
    case 1
        handles.Tracker = 'TrackMate';
    case 2
        handles.Tracker = 'Mosaic';
    otherwise
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function tracker_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tracker_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in process_button.
function process_button_Callback(hObject, eventdata, handles)
% hObject    handle to process_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% assert first that input track and tiff files are valid

tiff_fname = handles.tiffFile;
tracks_fname = handles.trackFile;

handles.img = tiff_read(tiff_fname);
img = handles.img;
[nrows, ncols, nframes] = size(img);
avgimg = mean(img, 3);

% now define seg
if handles.hasSegmentation 
    % ask if user would like to make a new segmentation
    quest='There is already a segmentation saved. Would you like to overwrite?';
    title='Draw new segmentation';
    yes='Yes, draw new.';
    no = 'No, use pre-existing.';
    answer = questdlg(quest,title,yes,no,no);
    switch answer
        case yes
            figure; imshow(mat2gray(avgimg));
            seg = roipoly;
            handles.seg=seg;
            fprintf('\n Segmentation saved! Proceeding...\n');
        case no
            seg=handles.seg;
            fprintf('\n Using pre-existing segmentation.\n');
    end
else    
    figure; imshow(mat2gray(avgimg))
    handles.seg = roipoly; 
    seg = handles.seg;
    handles.hasSegmentation = true;
end

if ~handles.hasTracks
    [X_noisy, V_noisy, tracks, tiff] = prepare(tiff_fname, tracks_fname, ...
        handles.partitionSize, handles.Tracker, handles.minPts);
    handles.hasTracks = true;
    handles.tracks = tracks;
else
    quest='There is already a tracks file. Re-read and overwrite?';
    title='Read new tracks file';
    yes='Yes, read new.';
    no = 'No, use pre-existing.';
    answer = questdlg(quest,title,yes,no,no);
    switch answer
        case yes
            [X_noisy, V_noisy, tracks, ~] = prepare(tiff_fname, ...
                    tracks_fname,handles.partitionSize, handles.Tracker,...
                    handles.minPts);
            handles.hasTracks = true;
            handles.tracks = tracks;
        case no
            tracks = handles.tracks;
            npts = handles.partitionSize;
            min_npts = handles.minPts;
            [X_noisy, V_noisy] = weightedtracklinfit(tracks,npts,min_npts);
    end
end

quest='Perform outlier detection?';
title = 'outlier detection';
yes = 'Yes';
no = 'No';
answer = questdlg(quest,title,yes,no,no);
switch answer
    case yes
        [X, V] = delOutliers(X_noisy, V_noisy, ...
                            handles.outlierDetectionTileSize, size(avgimg));
    case no
        X = X_noisy;
        V = V_noisy;
end

% assuming seg has been correctly defined into handles
approxMethod = handles.regressionApproxMethod;
[mu_x, mu_y, mu_xsd, mu_ysd, theta_width_x_optimal, noise_x_optimal, ...
    theta_width_y_optimal, noise_y_optimal,~, ~, signal_var] = ...
    hyperparams(X, V, seg, approxMethod);

handles.mu_x = mu_x;
handles.mu_y = mu_y;
handles.mu_xsd = mu_xsd;
handles.mu_ysd = mu_ysd;

handles.isProcessed = true;    
fprintf('Done processing!\n');
guidata(hObject, handles);

function tiff_input_editText_Callback(hObject, eventdata, handles)
% hObject    handle to tiff_input_Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tiff_input_Text as text
%        str2double(get(hObject,'String')) returns contents of tiff_input_Text as a double
input = get(hObject, 'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function tiff_input_Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tiff_input_Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function tracks_input_editText_Callback(hObject, eventdata, handles)
% hObject    handle to tracks_input_editText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tracks_input_editText as text
%        str2double(get(hObject,'String')) returns contents of tracks_input_editText as a double

input = get(hObject, 'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function tracks_input_editText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tracks_input_editText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in draw_seg_mask_pushButton.
function draw_seg_mask_pushButton_Callback(hObject, eventdata, handles)
% hObject    handle to draw_seg_mask_pushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assert(handles.img ~= 0)
avgimg = mean(img, 3);
figure; imshow(mat2gray(avgimg))
handles.seg = roipoly; 
guidata(hObject, handles);


% --- Executes on button press in view_colormaps_pushbutton.
function view_colormaps_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to view_colormaps_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assert(handles.isProcessed);
CONVERSION_FACTOR = 1.3158;
mu_x = handles.mu_x * CONVERSION_FACTOR;
mu_y = handles.mu_y * CONVERSION_FACTOR;
% let user pick one of vorticity, sdavg, or magnitude. set input values
list = {'Vorticity', 'Magnitude', 'Model Standard Deviation'};
[indx, tf] = listdlg('ListString', list, 'PromptString', 'Select desired display', ...
                        'SelectionMode', 'single');
                    
switch indx
    case 1
        vort = normalizedCurl(mu_x, mu_y);
        %input = abs(vort);
        input = vort;
        quantileLim = 0.999;
    case 2
        mags = sqrt(mu_x.^2 + mu_y.^2);
        input = mags;
        quantileLim = 0.97;
    otherwise
        sdnorm = sqrt(handles.mu_xsd.^2+handles.mu_ysd.^2);
        input = sdnorm;
        quantileLim = 0.98;
end
    
% get other parameter components
prompt = {'Enter sparsity of display:','Enter scale of display:', ...
    'Enter colorbar lowerlimit', 'Enter colorbar upperlimit:'};
title = 'Parameters for vector field visualization';
dims = [1 35];
PRODUCT_FOR_SCALE = 7;
% for getting suggested scaling
mags = sqrt(mu_x.^2 + mu_y.^2);
median_velocity = median(mags(mags~=0));
default_scale = PRODUCT_FOR_SCALE / median_velocity;
% for getting suggested colorbar upper limit
inputMags = input(handles.seg == 1);
default_cbLim = quantile(inputMags, quantileLim);
switch indx
    case 1
        default_lowerLim = -default_cbLim;
    otherwise
        default_lowerLim = 0;
end
% get user input
definput = {'15',num2str(default_scale), num2str(default_lowerLim), ...
            num2str(default_cbLim)};
answer = inputdlg(prompt,title,dims,definput);
sparsity = str2num(answer{1});
scale = str2num(answer{2});
lowerLim = str2num(answer{3});
cbLim = str2num(answer{4});


figure; vfcolormapdisplay(input, [lowerLim, cbLim], mu_x, mu_y, false, scale, sparsity);
figureH = gcf;
figureH;
cb = colorbar;
set(get(cb, 'title'), 'string', 'microns/frame');

% --- Executes on button press in visualize_vector_field_pushbutton.
function visualize_vector_field_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to visualize_vector_field_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assert(handles.isProcessed);
prompt = {'Enter sparsity of display:','Enter scale of display:'};
title = 'Parameters for vector field visualization';
dims = [1 35];
PRODUCT = 7;
mu_x = handles.mu_x;
mu_y = handles.mu_y;
% mags = sqrt(mu_x.^2 + mu_y.^2);
% median_velocity = median(mags(mags~=0));
% default_scale = PRODUCT / median_velocity;
definput = {'12','10'};
answer = inputdlg(prompt,title,dims,definput);
sparsity = str2num(answer{1});
scale = str2num(answer{2});

figure; vfquiverc(mu_x,mu_y,sparsity,scale);



% --- Executes on button press in process_express_pushbutton.
function process_express_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to process_express_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tiff_fname = handles.tiffFile;
tracks_fname = handles.trackFile;

handles.img = tiff_read(tiff_fname);
img = handles.img;
[nrows, ncols, nframes] = size(img);
avgimg = mean(img, 3);

% get user input
fixSpatial = true;
fixNoise = false;
prompt = {'Enter desired x-spatial kernel', 'Enter desired y-spatial kernel', ...
    'Enter desired x noise-to-signal ratio', 'Enter desired y noise-to-signal ratio'};
title = 'GPR parameters';
dims = [1 35];
definput = {'60', '60', '0.5', '0.5'};
answer = inputdlg(prompt,title,dims,definput);
xspatial = str2num(answer{1});
yspatial = str2num(answer{2});
xnsr = str2num(answer{3});
ynsr = str2num(answer{4});
nsr = [xnsr, ynsr];
spatial = [xspatial, yspatial];

if handles.hasSegmentation 
    % ask if user would like to make a new segmentation
    quest='There is already a segmentation saved. Would you like to overwrite?';
    title='Draw new segmentation';
    yes='Yes, draw new.';
    no = 'No, use pre-existing.';
    answer = questdlg(quest,title,yes,no,no);
    switch answer
        case yes
            figure; imshow(mat2gray(avgimg));
            seg = roipoly;
            handles.seg=seg;
            fprintf('\n Segmentation saved! Proceeding...\n');
        case no
            seg=handles.seg;
            fprintf('\n Using pre-existing segmentation.\n');
    end
else    
    figure; imshow(mat2gray(avgimg))
    handles.seg = roipoly; 
    seg = handles.seg;
    handles.hasSegmentation = true;
end

%read in tracks
if ~handles.hasTracks
    [X_noisy, V_noisy, tracks, tiff] = prepare(tiff_fname, tracks_fname, ...
        handles.partitionSize, handles.Tracker, handles.minPts);
    handles.hasTracks = true;
    handles.tracks = tracks;
else
    quest='There is already a tracks file. Re-read and overwrite?';
    title='Read new tracks file';
    yes='Yes, read new.';
    no = 'No, use pre-existing.';
    answer = questdlg(quest,title,yes,no,no);
    switch answer
        case yes
            [X_noisy, V_noisy, tracks, ~] = prepare(tiff_fname, ...
                    tracks_fname,handles.partitionSize, handles.Tracker,...
                    handles.minPts);
            handles.hasTracks = true;
            handles.tracks = tracks;
        case no
            tracks = handles.tracks;
            npts = handles.partitionSize;
            min_npts = handles.minPts;
            [X_noisy, V_noisy] = weightedtracklinfit(tracks,npts,min_npts);
    end
end


% ask about performing outlier detection            
quest='Perform outlier detection?';
title = 'outlier detection';
yes = 'Yes';
no = 'No';
answer = questdlg(quest,title,yes,no,no);
switch answer
    case yes
        [X, V] = delOutliers(X_noisy, V_noisy, ...
                            handles.outlierDetectionTileSize, size(avgimg));
    case no
        X = X_noisy;
        V = V_noisy;
end

% assuming seg has been correctly defined into handles, get user input and
% run gpregressor
[mu_x, mu_y, mu_xsd, mu_ysd, optxspatial, optxnoise, optyspatial, optynoise,...
            optxll, optyll, signal_var] = gpregressor(X, V, seg, spatial,...
                handles.regressionApproxMethod,nsr, fixSpatial, fixNoise);
handles.mu_x = mu_x;
handles.mu_y = mu_y;
handles.mu_xsd = mu_xsd;
handles.mu_ysd = mu_ysd;

handles.isProcessed = true;    
fprintf('Done processing!\n');
guidata(hObject, handles);


% --- Executes on button press in vector_field_over_image_pushbutton.
function vector_field_over_image_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to vector_field_over_image_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assert(handles.isProcessed);
prompt = {'Enter sparsity of display:','Enter scale of display:'};
title = 'Parameters for vector field visualization';
dims = [1 35];
PRODUCT = 7;
mu_x = handles.mu_x;
mu_y = handles.mu_y;
mags = sqrt(mu_x.^2 + mu_y.^2);
median_velocity = median(mags(mags~=0));
default_scale = PRODUCT / median_velocity;
definput = {'15',num2str(default_scale)};
answer = inputdlg(prompt,title,dims,definput);
sparsity = str2num(answer{1});
scale = str2num(answer{2});
avgimg = mean(handles.img,3);
figure; vf_overlay(mu_x, mu_y, avgimg, sparsity, scale, 'g', 1.5);


% --- Executes on button press in draw_segmentation_pushbutton.
function draw_segmentation_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to draw_segmentation_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tiff_fname = handles.tiffFile;

handles.img = tiff_read(tiff_fname);
img = handles.img;
avgimg = mean(img,3);
figure; imshow(mat2gray(avgimg));
handles.seg = roipoly;
handles.hasSegmentation = true;
fprintf('\n Segmentation saved! \n');
guidata(hObject, handles);

% --- Executes on button press in change_partition_size_pushbutton.
function change_partition_size_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to change_partition_size_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = {'Enter desired typical partition size', ...
    'Enter minimum number of points in partition required for fitting'};
title = 'Partition size for weighted least squares fitting';
dims = [1 35];
definput = {'33', '33'};
answer = inputdlg(prompt, title, dims, definput);
partitionSize = str2num(answer{1});
minPts = str2num(answer{2});
assert(minPts <= partitionSize);
handles.partitionSize = partitionSize;
handles.minPts = minPts;
fprintf('\n User changed typical partition size to %f \n', partitionSize);
fprintf('\n User changed minimum partition size to %f \n', minPts);
guidata(hObject, handles);


% --- Executes on button press in load_tiff_pushbutton.
function load_tiff_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to load_tiff_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uigetfile('*');
if isequal(file,0)
   disp('User selected Cancel')
else
   tiffFile = fullfile(path,file);
   disp(['User selected ', tiffFile]);
end
handles.tiffFile = tiffFile;
set(handles.tiff_file_name,'String', tiffFile);
guidata(hObject, handles);

% --- Executes on button press in load_track_file_pushbutton.
function load_track_file_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to load_track_file_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile('*');
if isequal(file,0)
   disp('User selected Cancel')
else
   trackFile = fullfile(path,file);
   disp(['User selected ', trackFile]);
end
handles.trackFile = trackFile;
set(handles.track_file_name,'String', trackFile);
guidata(hObject, handles);


% --- Executes on button press in open_roi_analyzer_pushbutton.
function open_roi_analyzer_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to open_roi_analyzer_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% opens a second gui to do ROI analysis, currently median speed
avgimg = mean(handles.img, 3);
ROIAnalyzer(avgimg, handles.seg, handles.mu_x, handles.mu_y)


% --- Executes on selection change in fitting_approximation_method_popup.
function fitting_approximation_method_popup_Callback(hObject, eventdata, handles)
% hObject    handle to fitting_approximation_method_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fitting_approximation_method_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fitting_approximation_method_popup

switch get(handles.fitting_approximation_method_popup, 'Value')
    case 1
        handles.regressionApproxMethod = 'sd';
    case 2
        handles.regressionApproxMethod = 'sr';
    case 3
        handles.regressionApproxMethod = 'exact';
    otherwise
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function fitting_approximation_method_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fitting_approximation_method_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_data_pushButton.
function save_data_pushButton_Callback(hObject, eventdata, handles)
% hObject    handle to save_data_pushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles
assignin('base', 'mu_x', handles.mu_x);
assignin('base', 'mu_y', handles.mu_y)
assignin('base', 'mu_xsd', handles.mu_xsd)
assignin('base', 'mu_ysd', handles.mu_ysd)
assignin('base', 'seg', handles.seg)
assignin('base', 'img', handles.img)
assignin('base', 'tracks', handles.tracks)