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

% Last Modified by GUIDE v2.5 30-Nov-2015 16:21:47

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

    dssize = size(images{1,1});

    set(handles.DataSetSlicer,'Min',1);
    set(handles.DataSetSlicer,'Max',dssize(3));
    set(handles.DataSetSlicer,'Value',1);

    cla(handles.DataSetAxes);

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

if isfield(handles,'visData')
    display_dataset(handles);
end

function display_dataset(handles)
val = floor(get(handles.DataSetSlicer,'Value'));
imshow(handles.visData{1,1}(:,:,val),[],'Parent',handles.DataSetAxes);
