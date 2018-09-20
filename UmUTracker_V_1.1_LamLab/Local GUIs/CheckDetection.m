%   This file is a demo of UMUTracker Project.The UMUTracker is currently under active development.
%	Related information can be found in the paper :
%
%	Hanqing Zhang, Tim Stangner, Krister Wiklund, Alvaro Rodriguez, Magnus Andersson
%	UmUTracker: A versatile MATLAB program for automated particle tracking of 2D light microscopy or 3D digital holography data
%
%	We welcome comments and contributions to the documentation and code of UMUTracker to help us improve the implementation.
%
%   Version: 1.Initial version:  Hanqing Zhang,hanqing.zhang@umu.se
%
function varargout = CheckDetection(varargin)
% CHECKDETECTION MATLAB code for CheckDetection.fig
%      CHECKDETECTION, by itself, creates a new CHECKDETECTION or raises the existing
%      singleton*.
%
%      H = CHECKDETECTION returns the handle to a new CHECKDETECTION or the handle to
%      the existing singleton*.
%
%      CHECKDETECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHECKDETECTION.M with the given input arguments.
%
%      CHECKDETECTION('Property','Value',...) creates a new CHECKDETECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CheckDetection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CheckDetection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CheckDetection

% Last Modified by GUIDE v2.5 20-Dec-2016 09:26:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CheckDetection_OpeningFcn, ...
                   'gui_OutputFcn',  @CheckDetection_OutputFcn, ...
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


% --- Executes just before CheckDetection is made visible.
function CheckDetection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CheckDetection (see VARARGIN)

% Choose default command line output for CheckDetection
handles.output = hObject;
handles.FromMain=varargin{1};

% Process Image
handles.image_in=handles.FromMain.DHMOperator.Image;
handles.high_thresh=max(eps,graythresh(handles.image_in));
high_thresh=handles.high_thresh/handles.FromMain.DHMOperator.DetectionConfig.Method.EdgeThresh;
Edge_canny=edge(handles.image_in,'canny',[high_thresh/3 high_thresh]);

figure(handles.figure_detection)
axes(handles.AXUES_IMAGE_BACKSUB);
imshow(handles.image_in);


figure(handles.figure_detection)
axes(handles.AXES_DetectionCheck);
imshow(Edge_canny);

set(handles.Slider_DetectionCheck,'value',handles.FromMain.DHMOperator.DetectionConfig.Method.EdgeThresh);
set(handles.Slider_DetectionCheck,'min',handles.high_thresh);
set(handles.Slider_DetectionCheck,'max',30);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CheckDetection wait for user response (see UIRESUME)
% uiwait(handles.figure_detection);


% --- Outputs from this function are returned to the command line.
function varargout = CheckDetection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function Slider_DetectionCheck_Callback(hObject, eventdata, handles)
% hObject    handle to Slider_DetectionCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Num=get(hObject,'Value');

high_thresh=handles.high_thresh/(Num+eps);
Edge_canny=edge(handles.image_in,'canny',[high_thresh/3 high_thresh]);

axes(handles.AXES_DetectionCheck);
imshow(Edge_canny);
handles.FromMain.DHMOperator.DetectionConfig.Method.EdgeThresh=Num;


% --- Executes during object creation, after setting all properties.
function Slider_DetectionCheck_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Slider_DetectionCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in Button_SaveDetectionCheck.
function Button_SaveDetectionCheck_Callback(hObject, eventdata, handles)
% hObject    handle to Button_SaveDetectionCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 % get the handle of Gui1
 h = findobj('Tag','figure_UmUTracker');
 if ~isempty(h) 
    Handle_DHM = guidata(h);
    Handle_DHM.DHMOperator.DetectionConfig.Method.EdgeThresh=...
        handles.FromMain.DHMOperator.DetectionConfig.Method.EdgeThresh;
    Handle_DHM.Config.DetectionConfig.Method.EdgeThresh=...
        handles.FromMain.DHMOperator.DetectionConfig.Method.EdgeThresh;
    set(Handle_DHM.PARA_Detection_CannyEdgeThreshHighMultiple,'String',num2str(Handle_DHM.DHMOperator.DetectionConfig.Method.EdgeThresh));
    set(Handle_DHM.Button_CheckDetection,'Enable','on');
    set(Handle_DHM.Button_StartDHM,'Enable','on');
    Func_ShowText(handles.FromMain.Axes_ProcessBar,'Ready to Start');
    
    set(Handle_DHM.PARA_Detection_CannyEdgeThreshHighMultiple,'Enable','on');
 end
 guidata(Handle_DHM.PARA_Detection_CannyEdgeThreshHighMultiple,Handle_DHM);
 close(handles.figure_detection);
 

% --- Executes during object deletion, before destroying properties.
function figure_detection_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure_detection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 h = findobj('Tag','figure_UmUTracker');
 if ~isempty(h) 
    Handle_DHM = guidata(h(1));
    set(Handle_DHM.PARA_Detection_CannyEdgeThreshHighMultiple,'String',num2str(Handle_DHM.DHMOperator.DetectionConfig.Method.EdgeThresh));
    set(Handle_DHM.Button_CheckDetection,'Enable','on');
    set(Handle_DHM.Button_StartDHM,'Enable','on');
    set(Handle_DHM.PARA_Detection_CannyEdgeThreshHighMultiple,'Enable','on');
 end
 guidata(Handle_DHM.PARA_Detection_CannyEdgeThreshHighMultiple,Handle_DHM);
