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
function varargout = CheckSingleTrack(varargin)
% CHECKSINGLETRACK MATLAB code for CheckSingleTrack.fig
%      CHECKSINGLETRACK, by itself, creates a new CHECKSINGLETRACK or raises the existing
%      singleton*.
%
%      H = CHECKSINGLETRACK returns the handle to a new CHECKSINGLETRACK or the handle to
%      the existing singleton*.
%
%      CHECKSINGLETRACK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHECKSINGLETRACK.M with the given input arguments.
%
%      CHECKSINGLETRACK('Property','Value',...) creates a new CHECKSINGLETRACK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CheckSingleTrack_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CheckSingleTrack_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CheckSingleTrack

% Last Modified by GUIDE v2.5 04-May-2017 10:00:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CheckSingleTrack_OpeningFcn, ...
                   'gui_OutputFcn',  @CheckSingleTrack_OutputFcn, ...
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


% --- Executes just before CheckSingleTrack is made visible.
function CheckSingleTrack_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CheckSingleTrack (see VARARGIN)

% Choose default command line output for CheckSingleTrack
handles.output = hObject;

CurrentFile = mfilename('fullpath');
[ProgramFolder, ~] = fileparts(CurrentFile);
if (~isdeployed)
    CurrentFile = mfilename('fullpath');
    [ProgramFolder, ~] = fileparts(CurrentFile);
    Functions_FilesName='LocalFunctions';
    Functions_FolderName=strcat(ProgramFolder,'\',Functions_FilesName);
    if ~exist(Functions_FolderName,'dir')
        mkdir(Functions_FolderName);
    end
    addpath(Functions_FolderName);
end

handles.PostP_Inst=CLASS_PostProcessing;
handles.PostP_Inst.LoadSingleFile;
if(handles.PostP_Inst.PostP_DataSize~=0)
    Time=handles.PostP_Inst.Collect(1);
    XDATA=handles.PostP_Inst.Collect(2)*1e6;
    YDATA=handles.PostP_Inst.Collect(3)*1e6;
    ZDATA=handles.PostP_Inst.Collect(4)*1e6;
    try
        Valid=handles.PostP_Inst.Collect(5);
        if(max(Valid(:))~=min(Valid(:)))
            Valid=(Valid-min(Valid(:)))/(max(Valid(:))-min(Valid(:)))+1;
        else
            Valid=ones(size(Valid));
        end
    catch
        Valid=ones(size(XDATA));
    end

    figure(handles.figure_postanalysis_singletrack)
    axes(handles.AXES_X);
    plot(XDATA);

    figure(handles.figure_postanalysis_singletrack)
    axes(handles.AXES_Y);
    plot(YDATA);

    figure(handles.figure_postanalysis_singletrack)
    axes(handles.AXES_Z);
    plot(ZDATA);
    
    figure(handles.figure_postanalysis_singletrack)
    axes(handles.AXES_XYZ);
    scatter3(XDATA,YDATA,ZDATA,20*Valid, Time,'filled');hold off;
    colormap(winter);
    hcolor =colorbar;
    hcolor.Label.String = 'Frame number';
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CheckSingleTrack wait for user response (see UIRESUME)
% uiwait(handles.figure_postanalysis_singletrack);


% --- Outputs from this function are returned to the command line.
function varargout = CheckSingleTrack_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure


% --- Executes on button press in LOAD_TRACK.
function LOAD_TRACK_Callback(hObject, eventdata, handles)
% hObject    handle to LOAD_TRACK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.PostP_Inst.LoadSingleFile;
if(handles.PostP_Inst.PostP_DataSize~=0)
    Time=handles.PostP_Inst.Collect(1);
    XDATA=handles.PostP_Inst.Collect(2)*1e6;
    YDATA=handles.PostP_Inst.Collect(3)*1e6;
    ZDATA=handles.PostP_Inst.Collect(4)*1e6;
    try
        Valid=handles.PostP_Inst.Collect(5);
        if(max(Valid(:))~=min(Valid(:)))
            Valid=(Valid-min(Valid(:)))/(max(Valid(:))-min(Valid(:)))+1;
        else
            Valid=ones(size(Valid));
        end
    catch
        Valid=ones(size(XDATA));
    end

    figure(handles.figure_postanalysis_singletrack)
    axes(handles.AXES_X);
    plot(XDATA);

    figure(handles.figure_postanalysis_singletrack)
    axes(handles.AXES_Y);
    plot(YDATA);

    figure(handles.figure_postanalysis_singletrack)
    axes(handles.AXES_Z);
    plot(ZDATA);
    
    figure(handles.figure_postanalysis_singletrack)
    axes(handles.AXES_XYZ);
    scatter3(XDATA,YDATA,ZDATA,20*Valid, Time,'filled');hold off;
    colormap(winter);
    hcolor =colorbar;
    hcolor.Label.String = 'Frame number';
end


% --- Executes on button press in BottomXYT.
function BottomXYT_Callback(hObject, eventdata, handles)
% hObject    handle to BottomXYT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.PostP_Inst.PostP_DataSize~=0)
    Time=handles.PostP_Inst.Collect(1);
    XDATA=handles.PostP_Inst.Collect(2)*1e6;
    YDATA=handles.PostP_Inst.Collect(3)*1e6;
    ZDATA=handles.PostP_Inst.Collect(4)*1e6;
    try
        Valid=handles.PostP_Inst.Collect(5);
        if(max(Valid(:))~=min(Valid(:)))
            Valid=(Valid-min(Valid(:)))/(max(Valid(:))-min(Valid(:)))+1;
        else
            Valid=ones(size(Valid));
        end
    catch
        Valid=ones(size(XDATA));
    end

    figure(handles.figure_postanalysis_singletrack)
    axes(handles.AXES_X);
    plot(XDATA);

    figure(handles.figure_postanalysis_singletrack)
    axes(handles.AXES_Y);
    plot(YDATA);

    figure(handles.figure_postanalysis_singletrack)
    axes(handles.AXES_Z);
    plot(ZDATA);
    
    figure(handles.figure_postanalysis_singletrack)
    axes(handles.AXES_XYZ);
    scatter3(XDATA,YDATA,ZDATA,20*Valid, Time,'filled');hold on;
    line(XDATA,YDATA,ZDATA);hold off;
    colormap(winter);
    hcolor =colorbar;
    hcolor.Label.String = 'Frame number';    
    dlmwrite('SingleTrack.txt',[XDATA,YDATA,ZDATA]);
end


% --- Executes during object deletion, before destroying properties.
function figure_postanalysis_singletrack_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure_postanalysis_singletrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OutputObj=findobj('Type','Figure');
delete_list=[];
for i=1:length(OutputObj)
    if(strcmp(OutputObj(i).Tag,'figure_postanalysis_singletrack'))
        delete_list(length(delete_list)+1)=i;
    end
end
delete(OutputObj(delete_list));