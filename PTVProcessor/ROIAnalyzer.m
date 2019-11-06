function varargout = ROIAnalyzer(varargin)
% ROIANALYZER MATLAB code for ROIAnalyzer.fig
%      ROIANALYZER, by itself, creates a new ROIANALYZER or raises the existing
%      singleton*.
%
%      H = ROIANALYZER returns the handle to a new ROIANALYZER or the handle to
%      the existing singleton*.
%
%      ROIANALYZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROIANALYZER.M with the given input arguments.
%
%      ROIANALYZER('Property','Value',...) creates a new ROIANALYZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROIAnalyzer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROIAnalyzer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROIAnalyzer

% Last Modified by GUIDE v2.5 01-Apr-2019 14:22:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROIAnalyzer_OpeningFcn, ...
                   'gui_OutputFcn',  @ROIAnalyzer_OutputFcn, ...
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


% --- Executes just before ROIAnalyzer is made visible.
function ROIAnalyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROIAnalyzer (see VARARGIN)

% Choose default command line output for ROIAnalyzer
handles.output = hObject;

% Update handles structure
img = varargin{1};
seg = varargin{2};
mu_x = varargin{3};
mu_y = varargin{4};

% default conversions
PIXELS2MICRONS_CONVERSIONFACTOR = 1.3158;
SECONDS2FRAMES_CONVERSIONFACTOR = 33;
CONVERSION_FACTOR = SECONDS2FRAMES_CONVERSIONFACTOR * ...
                                        PIXELS2MICRONS_CONVERSIONFACTOR;
handles.CONVERSION_FACTOR = CONVERSION_FACTOR; 

% using conversions, save initializing input into handles
handles.img = img;
handles.seg = seg;
handles.mu_x = mu_x * handles.CONVERSION_FACTOR;
handles.mu_y = mu_y * handles.CONVERSION_FACTOR;
handles.absoluteMin = 1;
handles.absoluteMax = size(img, 2); 

set(handles.limTopOuterSlider, 'Min', handles.absoluteMin);
set(handles.limTopOuterSlider, 'Max', handles.absoluteMax);
set(handles.limTopInnerSlider, 'Min', handles.absoluteMin);
set(handles.limTopInnerSlider, 'Max', handles.absoluteMax);
set(handles.limBottomOuterSlider, 'Min', handles.absoluteMin);
set(handles.limBottomOuterSlider, 'Max', handles.absoluteMax);
set(handles.limBottomInnerSlider, 'Min', handles.absoluteMin);
set(handles.limBottomInnerSlider, 'Max', handles.absoluteMax);

% values that change
handles.limTopOuter = handles.absoluteMin;
handles.limTopInner = handles.absoluteMax;
handles.limBottomOuter = handles.absoluteMin;
handles.limBottomInner = handles.absoluteMax;
handles.average_style = 'mean';
set(handles.limTopOuterSlider, 'Value', handles.absoluteMin);
set(handles.limTopInnerSlider, 'Value', handles.absoluteMax);
set(handles.limBottomOuterSlider, 'Value', handles.absoluteMin);
set(handles.limBottomInnerSlider, 'Value', handles.absoluteMax);

% update limits
set(handles.absoluteMaxDisplay, 'String', handles.absoluteMax);
set(handles.absoluteMinDisplay, 'String', handles.absoluteMin);

% show image
axes(handles.main_axes);
imshow(mat2gray(img)); hold on;
hold off;

% these are also updated every time a slider is moved. Initial update.
updateSliderValueDisplays(hObject,handles); 
roi = updateROIDisplay(hObject,handles); 
handles.roi = roi;
updateAvgSpeed(hObject,handles);

guidata(hObject, handles);


% UIWAIT makes ROIAnalyzer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ROIAnalyzer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function limTopOuterSlider_Callback(hObject, eventdata, handles)
% hObject    handle to limTopOuterSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

lim = round(get(handles.limTopOuterSlider, 'Value'));
handles.limTopOuter = lim;

updateSliderValueDisplays(hObject,handles); 
handles.roi = updateROIDisplay(hObject,handles); 
updateAvgSpeed(hObject,handles);

%guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function limTopOuterSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to limTopOuterSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on slider movement.
function limTopInnerSlider_Callback(hObject, eventdata, handles)
% hObject    handle to limTopInnerSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
lim = round(get(handles.limTopInnerSlider, 'Value'));
handles.limTopInner = lim;

updateSliderValueDisplays(hObject,handles); 
handles.roi = updateROIDisplay(hObject,handles); 
updateAvgSpeed(hObject,handles);

%guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function limTopInnerSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to limTopInnerSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function limBottomInnerSlider_Callback(hObject, eventdata, handles)
% hObject    handle to limBottomInnerSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
lim = round(get(handles.limBottomInnerSlider, 'Value'));
handles.limBottomInner = lim;

updateSliderValueDisplays(hObject,handles); 
handles.roi = updateROIDisplay(hObject,handles); 
updateAvgSpeed(hObject,handles);

%guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function limBottomInnerSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to limBottomInnerSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on slider movement.
function limBottomOuterSlider_Callback(hObject, eventdata, handles)
% hObject    handle to limBottomOuterSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
lim = round(get(handles.limBottomOuterSlider, 'Value'));
handles.limBottomOuter = lim;

updateSliderValueDisplays(hObject,handles); 
handles.roi = updateROIDisplay(hObject,handles); 
updateAvgSpeed(hObject,handles);

%guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function limBottomOuterSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to limBottomOuterSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end         

% ---------------the following are helper functions---------------

function updateSliderValueDisplays(hObject,handles)

    set(handles.limTopOuterSlider_valueDisplay, 'String', handles.limTopOuter);
    set(handles.limTopInnerSlider_valueDisplay, 'String', handles.limTopInner);
    set(handles.limBottomOuterSlider_valueDisplay, 'String', ...
                                                    handles.limBottomOuter);
    set(handles.limBottomInnerSlider_valueDisplay, 'String', ...
                                                    handles.limBottomInner);
    guidata(hObject,handles);


function roi = updateROIDisplay(hObject,handles)
    roi = getRegionOfInterest(handles.limTopOuter,handles.limTopInner,...
                            handles.limBottomOuter,handles.limBottomInner,...
                            handles.seg);
    seg = handles.seg;
    roiInSeg = min(roi, seg);
    axes(handles.main_axes);
    img = handles.img;
    imshow(mat2gray(img)); hold on;
    roi_boundary = visboundaries(roiInSeg,'LineWidth', 0.5);
    hold off;
    guidata(hObject,handles);

function updateAvgSpeed(hObject,handles)
    seg = handles.seg;
    roi = handles.roi;
    roiInSeg = min(seg, roi);
    mean_speed = computeAvgSpeed(handles.mu_x, handles.mu_y, roiInSeg,...
                                                    handles.average_style);          
    set(handles.avgSpeedDisplay, 'String', mean_speed);
    guidata(hObject,handles);


function roi = getRegionOfInterest(limTopOuter,limTopInner,limBottomOuter,...
                                    limBottomInner, seg)

    roiLeftTop = min(limTopOuter, limTopInner); 
    roiRightTop = max(limTopOuter, limTopInner);
    roiLeftBottom = min(limBottomOuter, limBottomInner); 
    roiRightBottom = max(limBottomOuter, limBottomInner);
    
    [nrows, ncols] = size(seg);
    assert(max(roiRightBottom,roiRightTop) <= ncols);
    assert(min(roiLeftBottom,roiLeftTop) >= 1);
    
    x = [roiLeftTop, roiRightTop, roiRightBottom, roiLeftBottom];
    y = [1, 1, nrows, nrows];
    
    roi = poly2mask(x, y, nrows, ncols);
    
    
    
    
function avg_speed = computeAvgSpeed(mu_x, mu_y, roi, specifier)
    if nargin < 4
        specifier = 'mean';
    end
    mags = sqrt(mu_x.^2 + mu_y.^2);
    if strcmp(specifier, 'mean')
        avg_speed = mean(mags(roi == 1));
    elseif strcmp(specifier, 'median')
        avg_speed = median(mags(roi == 1));
    end


% --- Executes on selection change in average_selector_popup.
function average_selector_popup_Callback(hObject, eventdata, handles)
% hObject    handle to average_selector_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns average_selector_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from average_selector_popup
switch get(handles.average_selector_popup, 'Value')
    case 1
        handles.average_style = 'mean';
    case 2
        handles.average_style = 'median';
    otherwise
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function average_selector_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to average_selector_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
