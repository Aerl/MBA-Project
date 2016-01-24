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

% Last Modified by GUIDE v2.5 24-Jan-2016 16:26:47

% add scripts and stuff
addpath(genpath('loadDICOM'));
addpath(genpath('AOSLevelsetSegmentationToolboxM'));

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

global s;
s = struct('OriginalImages',{},'ResampledImages',{},'Names',{}, 'Segmentation',{}, 'BinarySegmentation', {});
global p;
p = struct('iterations',[],'delta_time',[],'gac_weight',[],'propagation_weight',...
    [],'mu',[],'resolution',{}, 'subsamplingIsOn',[], 'smoothDistanceFieldIsOn',[],...
    'gaussSize',[],'gaussSigma',[],'convergenceThreshold',[]);

p(1).iterations = 40;
p(1).delta_time = 1;
p(1).propagation_weight = 1e-6;
p(1).gac_weight = 1 - p(1).propagation_weight;
p(1).mu = 300;
p(1).subsamplingIsOn = 1;
p(1).smoothDistanceFieldIsOn = 0;
p(1).gaussSize = [10 10];
p(1).gaussSigma = 8;
p(1).convergenceThreshold = 0.07;
p(1).differenceMargin = 0.15;

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
    [names,images,orgIm] = loadDICOM(path);
    
    handles.orgIm = orgIm;

    handles.visData = images;
    handles.visNames = names;
    handles.visSegs = cell(1,size(images,2));
    handles.visSegsSlices = cell(1,size(images,2)*2);
    handles.maxIntensities = cellfun(@(x) max(max(max(x))), images,'UniformOutput',false);

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
    
    if(get(handles.normCheckbox,'Value'))
        I = handles.visData{1,vertebra_num}(:,:,slice_num);
        I = I/max(max(I));
    else
        I = handles.visData{1,vertebra_num}(:,:,slice_num)/handles.maxIntensities{1,vertebra_num};
    end

    if(isfield(handles,'visSegs') && ~isempty(handles.visSegs{1,vertebra_num}) && isfield(handles,'visSegsSlices') && slice_num >= handles.visSegsSlices{2*vertebra_num-1} && ~isempty(handles.visSegsSlices{2*vertebra_num}) && slice_num <= handles.visSegsSlices{2*vertebra_num})
        RGB = repmat(I,[1,1,3]); % convert I to an RGB image 
        RGB = insertShape(RGB, 'rectangle', handles.visSegs{1,vertebra_num} , 'LineWidth', 1);
        imshow(RGB,'Parent',handles.DataSetAxes);
    else
        imshow(I,[0.0 1.0],'Parent',handles.DataSetAxes);
    end

    set(imhandles(handles.DataSetAxes),'ButtonDownFcn',@SliceImageButtonDownFun);
    
    % build info text
    infoString = '';
    infoString = strcat(infoString,sprintf('Vertebrae: %d',vertebra_num));
    infoString = strcat(infoString,sprintf('\nSlice: %d',slice_num));
    
    % display info text
    set(handles.InfoDisplay,'String',infoString);    
    
    %build segmentation info string
    if(isfield(handles,'visSegsSlices') && isfield(handles,'visSegs'))
        rect = handles.visSegs{1,vertebra_num};
        if(~isempty(rect))
            set(handles.p1x,'String',sprintf('\tx: %.2f',rect(1)));
            set(handles.p1y,'String',sprintf('\ty: %.2f',rect(2)));
            set(handles.p1slice,'String',sprintf('\tslice: %d',handles.visSegsSlices{2*vertebra_num-1}));        
        else
            set(handles.p1x,'String',sprintf('\tx:'));
            set(handles.p1y,'String',sprintf('\ty:'));
            set(handles.p1slice,'String',sprintf('\tslice:'));               
        end
        if(length(rect) > 2)
            set(handles.p2x,'String',sprintf('\tx: %.2f',rect(1)+rect(3)));
            set(handles.p2y,'String',sprintf('\ty: %.2f',rect(2)+rect(4)));
            set(handles.p2slice,'String',sprintf('\tslice: %d',handles.visSegsSlices{2*vertebra_num}));                
        else
            set(handles.p2x,'String',sprintf('\tx:'));
            set(handles.p2y,'String',sprintf('\ty:'));    
            set(handles.p2slice,'String',sprintf('\tslice:')); 
        end
    end
    
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
    handles.visSegs{1,vertebra_num} = zeros(1,2);
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


% --- Executes on button press in resetSegButton.
function resetSegButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetSegButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(isfield(handles,'visSegs'))
    vertebra_num = get(handles.DataSetPopUp,'Value');
    handles.visSegs{1,vertebra_num} = [];
    handles.visSegsSlices{2*vertebra_num-1} = [];
    handles.visSegsSlices{2*vertebra_num} = [];
    
    guidata(hObject,handles);
    
    display_dataset(handles);
end


% --- Executes on button press in startSegmButton.
function startSegmButton_Callback(hObject, eventdata, handles)
% hObject    handle to startSegmButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global p;
global s;

vertebra = get(handles.DataSetPopUp,'Value');

if(isfield(handles,'visSegs') && ~isempty(handles.visSegs{1,vertebra}))
    
    [fileName,pathName] = uiputfile({'*.mat'},'Save Result as ...','segmentation.mat');
    
    s(1).Names = handles.visNames;
    s(1).ResampledImages = handles.visData;
    s(1).OriginalImages = handles.orgIm;    

    % select Vertebra
    if (p(1).subsamplingIsOn)
        sz = size(s(1).ResampledImages{vertebra});
    else
        sz = size(s(1).OriginalImages{vertebra});
    end
    
    if(~get(handles.UseUserInitSeg,'Value'));
        
        margin = floor([(handles.visSegs{1,vertebra}(3)/2) ...
            (handles.visSegs{1,vertebra}(4)/2) ...
            (handles.visSegsSlices{2*vertebra}-handles.visSegsSlices{2*vertebra-1})/2]);

        center = floor([handles.visSegs{1,vertebra}(1)+margin(1) ...
            handles.visSegs{1,vertebra}(2)+margin(2)...
            handles.visSegsSlices{2*vertebra-1} + margin(3)]);

        distance_field = initialize_distance_field(sz, center, margin, 0.5);
    else
       
        distance_field = distanceFieldByGT(floor([handles.visSegs{1,vertebra}(1:2) handles.visSegsSlices{2*vertebra-1}]), floor([handles.visSegs{1,vertebra}(3:4) (handles.visSegsSlices{2*vertebra}-handles.visSegsSlices{2*vertebra-1})]), vertebra,sz); 
        
    end
    [s(1).Segmentation{vertebra}, s(1).BinarySegmentation{vertebra}] = segmentVertebra(vertebra,s(1).ResampledImages{vertebra},s(1).OriginalImages{vertebra},distance_field);

    title = strcat('Result ',' - Vertebra  ',num2str(vertebra));
    figure('name',title,'numbertitle','off');
    sizeIMG = size(s(1).OriginalImages{vertebra}(:,:,1));

    for i = 1:15
        subplot(3,5,i);
        imshow(s(1).OriginalImages{vertebra}(:,:,i),[]);
        red = cat(3, ones(sizeIMG),zeros(sizeIMG), zeros(sizeIMG));
        hold on;
        hr = imshow(red);
        hold off;
        set(hr, 'AlphaData',0.3* s(1).BinarySegmentation{vertebra}(:,:,i))
        set(hr, 'AlphaData',0.3* s(1).BinarySegmentation{vertebra}(:,:,i))
    end
    
    res = s(1).BinarySegmentation{vertebra};
    save(strcat(pathName,fileName),'res');
    
else
    warning('no initial Segmentation set');
end

% --- Executes on button press in p1xdown.
function p1xdown_Callback(hObject, eventdata, handles)
% hObject    handle to p1xdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vertebra_num = get(handles.DataSetPopUp,'Value');

if(isfield(handles,'visSegs') && ~isempty(handles.visSegs{1,vertebra_num}))
    handles.visSegs{1,vertebra_num}(1) = handles.visSegs{1,vertebra_num}(1) - 1.0;
    handles.visSegs{1,vertebra_num}(3) = handles.visSegs{1,vertebra_num}(3) + 1.0;
end

% update handles
guidata(hObject,handles);

display_dataset(handles);

% --- Executes on button press in p1xup.
function p1xup_Callback(hObject, eventdata, handles)
% hObject    handle to p1xup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vertebra_num = get(handles.DataSetPopUp,'Value');

if(isfield(handles,'visSegs') && ~isempty(handles.visSegs{1,vertebra_num}))
    handles.visSegs{1,vertebra_num}(1) = handles.visSegs{1,vertebra_num}(1) + 1.0;
    handles.visSegs{1,vertebra_num}(3) = handles.visSegs{1,vertebra_num}(3) - 1.0;
end

% update handles
guidata(hObject,handles);

display_dataset(handles);

% --- Executes on button press in p1ydown.
function p1ydown_Callback(hObject, eventdata, handles)
% hObject    handle to p1ydown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vertebra_num = get(handles.DataSetPopUp,'Value');

if(isfield(handles,'visSegs') && ~isempty(handles.visSegs{1,vertebra_num}))
    handles.visSegs{1,vertebra_num}(2) = handles.visSegs{1,vertebra_num}(2) + 1.0;
    handles.visSegs{1,vertebra_num}(4) = handles.visSegs{1,vertebra_num}(4) - 1.0;
end

% update handles
guidata(hObject,handles);

display_dataset(handles);


% --- Executes on button press in p1yup.
function p1yup_Callback(hObject, eventdata, handles)
% hObject    handle to p1yup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vertebra_num = get(handles.DataSetPopUp,'Value');

if(isfield(handles,'visSegs') && ~isempty(handles.visSegs{1,vertebra_num}))
    handles.visSegs{1,vertebra_num}(2) = handles.visSegs{1,vertebra_num}(2) - 1.0;
    handles.visSegs{1,vertebra_num}(4) = handles.visSegs{1,vertebra_num}(4) + 1.0;
end

% update handles
guidata(hObject,handles);

display_dataset(handles);


% --- Executes on button press in p2xup.
function p2xup_Callback(hObject, eventdata, handles)
% hObject    handle to p2xup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vertebra_num = get(handles.DataSetPopUp,'Value');

if(isfield(handles,'visSegs') && ~isempty(handles.visSegs{1,vertebra_num}))
    handles.visSegs{1,vertebra_num}(3) = handles.visSegs{1,vertebra_num}(3) + 1.0;
end

% update handles
guidata(hObject,handles);

display_dataset(handles);


% --- Executes on button press in p2xdown.
function p2xdown_Callback(hObject, eventdata, handles)
% hObject    handle to p2xdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vertebra_num = get(handles.DataSetPopUp,'Value');

if(isfield(handles,'visSegs') && ~isempty(handles.visSegs{1,vertebra_num}))
    handles.visSegs{1,vertebra_num}(3) = handles.visSegs{1,vertebra_num}(3) - 1.0;
end

% update handles
guidata(hObject,handles);

display_dataset(handles);

% --- Executes on button press in p2ydown.
function p2ydown_Callback(hObject, eventdata, handles)
% hObject    handle to p2ydown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vertebra_num = get(handles.DataSetPopUp,'Value');

if(isfield(handles,'visSegs') && ~isempty(handles.visSegs{1,vertebra_num}))
    handles.visSegs{1,vertebra_num}(4) = handles.visSegs{1,vertebra_num}(4) - 1.0;
end

% update handles
guidata(hObject,handles);

display_dataset(handles);


% --- Executes on button press in p2yup.
function p2yup_Callback(hObject, eventdata, handles)
% hObject    handle to p2yup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vertebra_num = get(handles.DataSetPopUp,'Value');

if(isfield(handles,'visSegs') && ~isempty(handles.visSegs{1,vertebra_num}))
    handles.visSegs{1,vertebra_num}(4) = handles.visSegs{1,vertebra_num}(4) + 1.0;
end

% update handles
guidata(hObject,handles);

display_dataset(handles);

% --- Executes on button press in p2slicedown.
function p2slicedown_Callback(hObject, eventdata, handles)
% hObject    handle to p2slicedown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vertebra_num = get(handles.DataSetPopUp,'Value');

if(~isempty(handles.visSegsSlices{2*vertebra_num}))
    handles.visSegsSlices{2*vertebra_num} = handles.visSegsSlices{2*vertebra_num} -1;
end

% update handles
guidata(hObject,handles);

display_dataset(handles);

% --- Executes on button press in p2sliceup.
function p2sliceup_Callback(hObject, eventdata, handles)
% hObject    handle to p2sliceup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vertebra_num = get(handles.DataSetPopUp,'Value');

if(~isempty(handles.visSegsSlices{2*vertebra_num}))
    handles.visSegsSlices{2*vertebra_num} = handles.visSegsSlices{2*vertebra_num} + 1;
end

% update handles
guidata(hObject,handles);

display_dataset(handles);

% --- Executes on button press in p1sliceup.
function p1sliceup_Callback(hObject, eventdata, handles)
% hObject    handle to p1sliceup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vertebra_num = get(handles.DataSetPopUp,'Value');

if(~isempty(handles.visSegsSlices{2*vertebra_num-1}))
    handles.visSegsSlices{2*vertebra_num-1} = handles.visSegsSlices{2*vertebra_num-1} +1;
end

% update handles
guidata(hObject,handles);

display_dataset(handles);


% --- Executes on button press in p1slicedown.
function p1slicedown_Callback(hObject, eventdata, handles)
% hObject    handle to p1slicedown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vertebra_num = get(handles.DataSetPopUp,'Value');

if(~isempty(handles.visSegsSlices{2*vertebra_num-1}))
    handles.visSegsSlices{2*vertebra_num-1} = handles.visSegsSlices{2*vertebra_num-1} -1;
end

% update handles
guidata(hObject,handles);

display_dataset(handles);


% --- Executes on button press in UseUserInitSeg.
function UseUserInitSeg_Callback(hObject, eventdata, handles)
% hObject    handle to UseUserInitSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UseUserInitSeg


% --- Executes on button press in normCheckbox.
function normCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to normCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of normCheckbox
display_dataset(handles);


