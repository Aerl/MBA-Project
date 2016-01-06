function varargout = MBA(varargin)
% MBA MATLAB code for MBA.fig
%      MBA, by itself, creates a new MBA or raises the existing
%      singleton*.
%
%      H = MBA returns the handle to a new MBA or the handle to
%      the existing singleton*.
%
%      MBA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MBA.M with the given input arguments.
%
%      MBA('Property','Value',...) creates a new MBA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MBA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MBA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MBA

% Last Modified by GUIDE v2.5 12-Dec-2015 17:04:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MBA_OpeningFcn, ...
                   'gui_OutputFcn',  @MBA_OutputFcn, ...
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

% --- Executes just before MBA is made visible.
function MBA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MBA (see VARARGIN)

% Choose default command line output for MBA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MBA wait for user response (see UIRESUME)
% uiwait(handles.figure1);

addlistener(handles.DataSetSlicer,'ContinuousValueChange',@DataSetSlicer_ContiniousCallback);


% --- Outputs from this function are returned to the command line.
function varargout = MBA_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in LoadDataSetButton.
function LoadDataSetButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadDataSetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

directory = uigetdir();

if(ischar(directory))
    path = getAllFiles(directory);
    [names,images] = loadDICOM(path);

    handles.visData = images;
    handles.visNames = names;
    handles.visSegs = cell(1,size(images,2));
    handles.visSegsSlices = cell(1,size(images,2)*2);

    dssize = size(images{1,1});

    set(handles.DataSetSlicer,'Min',1);
    set(handles.DataSetSlicer,'Max',dssize(3));
    set(handles.DataSetSlicer,'Value',1);
    
    set(handles.DataSetPopUp,'String',names);
    
    display_dataset(handles);

    % Update handles structure
    guidata(hObject, handles);
end


% --- Executes on slider movement.
function DataSetSlicer_Callback(hObject, eventdata, handles)
% hObject    handle to DataSetSlicer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider




% --- Executes during object creation, after setting all properties.
function DataSetSlicer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DataSetSlicer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function DataSetSlicer_ContiniousCallback(hObject,eventData)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% first we need the handles structure which we can get from hObject
handles = guidata(hObject);


display_dataset(handles);

function display_dataset(handles)

if isfield(handles,'visData')
    slice_num = floor(get(handles.DataSetSlicer,'Value'));
    vertebra_num = get(handles.DataSetPopUp,'Value');
    I = handles.visData{1,vertebra_num}(:,:,slice_num);

    if(isfield(handles,'visSegs') && ~isempty(handles.visSegs{1,vertebra_num}) && isfield(handles,'visSegsSlices') && slice_num >= handles.visSegsSlices{2*vertebra_num-1} && ~isempty(handles.visSegsSlices{2*vertebra_num}) && slice_num <= handles.visSegsSlices{2*vertebra_num})
        RGB = repmat(I,[1,1,3]); % convert I to an RGB image
        RGB = RGB/max(max(I)); 
        RGB = insertShape(RGB, 'rectangle', handles.visSegs{1,vertebra_num} , 'LineWidth', 1);
        imshow(RGB,'Parent',handles.DataSetAxes);
    else
        imshow(I,[],'Parent',handles.DataSetAxes);
    end

    set(imhandles(handles.DataSetAxes),'ButtonDownFcn',@SliceImageButtonDownFun);
end

% --- Executes on selection change in DataSetPopUp.
function DataSetPopUp_Callback(hObject, eventdata, handles)
% hObject    handle to DataSetPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DataSetPopUp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DataSetPopUp
display_dataset(handles)

% --- Executes during object creation, after setting all properties.
function DataSetPopUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DataSetPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over axes background.
function SliceImageButtonDownFun(hObject, eventdata)

handles = guidata(hObject);

coordinates = get(get(hObject,'Parent'),'CurrentPoint');
coordinates = [coordinates(1,1) coordinates(1,2)];

%rectangle = getrect(handles.DataSetAxes);
vertebra_num = get(handles.DataSetPopUp,'Value');
%

slice_num = floor(get(handles.DataSetSlicer,'Value'));
if(~isempty(handles.visSegsSlices{2*vertebra_num-1}) && ~isempty(handles.visSegsSlices{2*vertebra_num}) ||  isempty(handles.visSegsSlices{2*vertebra_num-1}) && isempty(handles.visSegsSlices{2*vertebra_num}))
    handles.visSegsSlices{2*vertebra_num-1} = slice_num;
    handles.visSegsSlices{2*vertebra_num} = [];
    handles.visSegs{1,vertebra_num}(1:2) = coordinates;
else
    handles.visSegsSlices{2*vertebra_num} = slice_num;
    handles.visSegs{1,vertebra_num}(3:4)= coordinates-handles.visSegs{1,vertebra_num}(1:2);
    if(handles.visSegsSlices{2*vertebra_num} < handles.visSegsSlices{2*vertebra_num-1})
        temp = handles.visSegsSlices{2*vertebra_num-1};
        handles.visSegsSlices{2*vertebra_num-1} = handles.visSegsSlices{2*vertebra_num};
        handles.visSegsSlices{2*vertebra_num} = temp;
    end
end

% update handles
guidata(hObject,handles);

display_dataset(handles);
