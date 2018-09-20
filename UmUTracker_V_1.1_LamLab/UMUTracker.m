 

function varargout = UMUTracker(varargin)
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

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @UMUTracker_OpeningFcn, ...
    'gui_OutputFcn',  @UMUTracker_OutputFcn, ...
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
% -----------------------Initialize----------------------------------------
function UMUTracker_OpeningFcn(hObject, ~, handles, varargin)
%%
handles.output = hObject;
%% Check GPU
try
        gpuArray(1);
        disp('Preparing configurations... GPU based functions are available.');
        GPU_Active=1;
catch        
        disp('Fail to locate GPUs for the program');
        GPU_Active=0;
end
%% Update local folders 
if (~isdeployed)
    CurrentFile = mfilename('fullpath');
    [ProgramFolder, ~] = fileparts(CurrentFile);
    Functions_FilesName='LocalFunctions';
    Functions_FolderName=strcat(ProgramFolder,'\',Functions_FilesName);
    if ~exist(Functions_FolderName,'dir')
        mkdir(Functions_FolderName);
    end
    addpath(Functions_FilesName);
    Interfaces_FilesName='Interfaces';
    Interfaces_FolderName=strcat(ProgramFolder,'\',Interfaces_FilesName);
    if ~exist(Interfaces_FolderName,'dir')
        mkdir(Interfaces_FolderName);
    end
    addpath(Interfaces_FilesName);
    GUIs_FilesName='Local GUIs';
    GUIs_FolderName=strcat(ProgramFolder,'\',GUIs_FilesName);
    if ~exist(GUIs_FolderName,'dir')
        mkdir(GUIs_FolderName);
    end
    addpath(GUIs_FilesName);
    Acc_FilesName='Acceleration';
    Acc_FolderName=strcat(ProgramFolder,'\',Acc_FilesName);
    if ~exist(Acc_FolderName,'dir')
        mkdir(Acc_FolderName);
    end
    addpath(Acc_FilesName); 
end
%% Update Control parameters
% Controls for tracking
set(handles.output, 'UserData',[]);
SystemParameters.stop = false;
SystemParameters.pause = false;
set(handles.Button_Continue_Pause_DHM,'String','Pause');
% Save & Load parameters
SystemParameters.SaveConfigName = 'Config_AUTOSAVE';
set(handles.TEXT_PARA_SAVE_CONFIG,'String',SystemParameters.SaveConfigName);
% Update system parameters
set(handles.output, 'UserData',SystemParameters);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize parameters
handles.Config=GUI_DHMTrack_initialization;
if(GPU_Active*handles.Config.GPUConfig.Active==1)
    handles.Config.GPUConfig.Active=1;
else
    handles.Config.GPUConfig.Active=0;
    disp('GPU based functions are de-activated.');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize instances
handles.DataSource=CLASS2_LOADVI_IMPLEMENTATION_LoadVideo;
handles=InitializeParameters(handles);
%% Update handles structure
guidata(hObject, handles);
function handles=InitializeParameters(handles)
%% Computing Cores
if isempty(gcp('nocreate'))==1 % checking to see if my pool is already open
    ParCluster.NumWorkers=handles.Config.CPUConfig.Cores;
    parpool(ParCluster.NumWorkers);
else
    ParCluster=parcluster('local');
    ParCluster.NumWorkers=handles.Config.CPUConfig.Cores;
end
if(handles.Config.CPUConfig.ParForActive==1)
    set(handles.PARA_ActivateCPUComputing,'Value',1);
else
    set(handles.PARA_ActivateCPUComputing,'Value',0);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize instances
handles.DHMOperator=CLASS_DHMTracking_IMPLEMENTATION(handles.Config);
handles.DataCollector=CLASS_CollectData_IMPLEMENTATION(handles.Config);
%handles.PostProcssor=CLASS_PostProcessing;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize GUI
%% Customized GUIs
handles.Axes_ProcessBar=axes( ...
            'Units','pixels',...
            'Color','w',...
            'XColor','w','YColor','w', ...
            'OuterPosition',[460 152 381 30],...
            'Position',[460 152 381 30],...
            'Xlimmode','auto',...
            'Ylimmode','auto',...
            'XLim', [0 1], ...
            'YLim', [0 1], ...
            'Box', 'on', ...
            'ytick', [], ...
            'xtick', [] );
 text(0.5, 0.5,'UmUTracker', ...
            'HorizontalAlignment', 'center', ...
            'Parent',handles.Axes_ProcessBar,...
            'FontUnits', 'Normalized', ...
            'FontSize', 0.7 );
        
handles.MethodGroup = uitabgroup('Parent', handles.DetectionGroup,'Unit','Centimeter','Position',[0.5 0.3 14 2.8],'OuterPosition', [0.5 0.3 14 2.8]);
handles.MethodGroup_Tab_Manual = uitab('Parent', handles.MethodGroup, 'Title', 'Manually select circles','ButtonDownFcn',@(hObject,eventdata)UMUTracker('MethodGroup_Tab_Manual_Callback',hObject,eventdata,guidata(hObject)));
handles.MethodGroup_Tab_Blob = uitab('Parent', handles.MethodGroup, 'Title', 'Blob detection','ButtonDownFcn',@(hObject,eventdata)UMUTracker('MethodGroup_Tab_Blob_Callback',hObject,eventdata,guidata(hObject)));
handles.MethodGroup_Tab_ITs = uitab('Parent', handles.MethodGroup, 'Title', 'ITs transform auto-detection','ButtonDownFcn',@(hObject,eventdata)UMUTracker('MethodGroup_Tab_ITs_Callback',hObject,eventdata,guidata(hObject)));

% ITs
set(handles.CONST_TEXT_PARA_Detection_ITCiD_ScaleNum,'Parent',handles.MethodGroup_Tab_ITs,'Unit','Centimeter','Position',[0 0.2 3 0.4],'OuterPosition',[0 0.2 3 0.4]);
set(handles.PARA_Detection_ITCiD_ScaleNum,'Parent',handles.MethodGroup_Tab_ITs,'Unit','Centimeter','Position',[3.1 0.2 1 0.5],'OuterPosition',[3.1 0.2 1 0.5]);

set(handles.CONST_TEXT_PARA_Detection_ITMinVotes,'Parent',handles.MethodGroup_Tab_ITs,'Unit','Centimeter','Position',[0 1.1 3 0.4],'OuterPosition',[0 1.1 3 0.4]);
set(handles.PARA_Detection_ITMinVotes,'Parent',handles.MethodGroup_Tab_ITs,'Unit','Centimeter','Position',[3.1 1.1 1 0.5],'OuterPosition',[3.1 1.1 1 0.5]);
 
set(handles.CONST_TEXT_PARA_Detection_ITThreshold,'Parent',handles.MethodGroup_Tab_ITs,'Unit','Centimeter','Position',[4.5 0.2 3 0.4],'OuterPosition',[4.5 0.2 3 0.4]);
set(handles.PARA_Detection_ITThreshold,'Parent',handles.MethodGroup_Tab_ITs,'Unit','Centimeter','Position',[7.6 0.2 1 0.5],'OuterPosition',[7.6 0.2 1 0.5]);

set(handles.CONST_TEXT_PARA_Detection_Iterations,'Parent',handles.MethodGroup_Tab_ITs,'Unit','Centimeter','Position',[4.5 1.1 3 0.4],'OuterPosition',[4.5 1.1 3 0.4]);
set(handles.PARA_Detection_Iterations,'Parent',handles.MethodGroup_Tab_ITs,'Unit','Centimeter','Position',[7.6 1.1 1 0.5],'OuterPosition',[7.6 1.1 1 0.5]);

set(handles.CONST_TEXT_PARA_Detection_ITCiD_LineLength,'Parent',handles.MethodGroup_Tab_ITs,'Unit','Centimeter','Position',[9 0.2 3 0.4],'OuterPosition',[9 0.2 3 0.4]);
set(handles.PARA_Detection_ITCiD_LineLength,'Parent',handles.MethodGroup_Tab_ITs,'Unit','Centimeter','Position',[12.1 0.2 1 0.5],'OuterPosition',[12.1 0.2 1 0.5]);

set(handles.CONST_TEXT_PARA_Detection_ITCiD_MappingSize,'Parent',handles.MethodGroup_Tab_ITs,'Unit','Centimeter','Position',[9 1.1 3 0.4],'OuterPosition',[9 1.1 3 0.4]);
set(handles.PARA_Detection_ITCiD_MappingSize,'Parent',handles.MethodGroup_Tab_ITs,'Unit','Centimeter','Position',[12.1 1.1 1 0.5],'OuterPosition',[12.1 1.1 1 0.5]);

% Blob detection

set(handles.CONST_TEXT_PARA_BlobDetection_MinSize,'Parent',handles.MethodGroup_Tab_Blob,'Unit','Centimeter','Position',[0 0.2 3 0.4],'OuterPosition',[0 0.2 3 0.4]);
set(handles.PARA_BlobDetection_MinSize,'Parent',handles.MethodGroup_Tab_Blob,'Unit','Centimeter','Position',[3.1 0.2 1 0.5],'OuterPosition',[3.1 0.2 1 0.5]);

set(handles.CONST_TEXT_PARA_BlobDetection_MaxSize,'Parent',handles.MethodGroup_Tab_Blob,'Unit','Centimeter','Position',[4.5 0.2 3 0.4],'OuterPosition',[4.5 0.2 3 0.4]);
set(handles.PARA_BlobDetection_MaxSize,'Parent',handles.MethodGroup_Tab_Blob,'Unit','Centimeter','Position',[7.6 0.2 1 0.5],'OuterPosition',[7.6 0.2 1 0.5]);


set(handles.CONST_TEXT_PARA_BlobDetection_MorphKernelSize,'Parent',handles.MethodGroup_Tab_Blob,'Unit','Centimeter','Position',[0 1.1 3 0.4],'OuterPosition',[0 1.1 3 0.4]);
set(handles.PARA_BlobDetection_MorphKernelSize,'Parent',handles.MethodGroup_Tab_Blob,'Unit','Centimeter','Position',[3.1 1.1 1 0.5],'OuterPosition',[3.1 1.1 1 0.5]);

set(handles.CONST_TEXT_PARA_BlobDetection_IntensityMaskThresholdValue,'Parent',handles.MethodGroup_Tab_Blob,'Unit','Centimeter','Position',[4.5 1.1 3 0.4],'OuterPosition',[4.5 1.1 3 0.4]);
set(handles.PARA_BlobDetection_IntensityMaskThresholdValue,'Parent',handles.MethodGroup_Tab_Blob,'Unit','Centimeter','Position',[7.6 1.1 1 0.5],'OuterPosition',[7.6 1.1 1 0.5]);

% Manual
set(handles.CONST_TEXT_PARA_Detection_Manual_Instruction,'Parent',handles.MethodGroup_Tab_Manual,'Unit','Centimeter','Position',[0 0.3 10 1],'OuterPosition',[0 0.3 10 1]);


%% Buttons
set(handles.Button_StartDHM,'Enable','off');
set(handles.Button_StopDHM,'Enable','off');
set(handles.Button_Continue_Pause_DHM,'Enable','off');
set(handles.Button_CheckDetection,'Enable','off');
set(handles.PARA_Preprocessing_BackgroundMethod_Const,'Enable','off');
set(handles.PARA_Preprocessing_BackgroundMethod_Moving,'Enable','off');
%% Pre-processing Parameters
if(strcmp(handles.Config.PreProcessConfig.Backgroundsubtraction,'On') && strcmp(handles.Config.PreProcessConfig.Backgroundnorm,'Off'))
    set(handles.Check_BackgroundSub,'Value',0);
    set(handles.PARA_Preprocessing_Background,'Value',1);
    set(handles.PARA_Preprocessing_Background_NumofFrames,'Enable','on');
    set(handles.CONST_TEXT_Preprocessing_Background,'Enable','on');
elseif(strcmp(handles.Config.PreProcessConfig.Backgroundnorm,'On') && strcmp(handles.Config.PreProcessConfig.Backgroundsubtraction,'Off'))
    set(handles.Check_BackgroundSub,'Value',1);
    set(handles.PARA_Preprocessing_Background,'Value',0);
    set(handles.PARA_Preprocessing_Background_NumofFrames,'Enable','on');
    set(handles.CONST_TEXT_Preprocessing_Background,'Enable','on');
else
    set(handles.PARA_Preprocessing_Background,'Value',0);
    set(handles.PARA_Preprocessing_Background_NumofFrames,'Enable','off');
    set(handles.CONST_TEXT_Preprocessing_Background,'Enable','off');
end
if(strcmp(handles.Config.PreProcessConfig.IntensityRescaling,'On'))
    set(handles.PARA_Preprocessing_IntensityScaling,'Value',1);
else
    set(handles.PARA_Preprocessing_IntensityScaling,'Value',0);
end
if(handles.Config.PreProcessConfig.Resize.On==1)
    set(handles.PARA_Preprocessing_ImageResize,'Value',1);
    set(handles.PARA_Preprocessing_ImageResize_factor,'Enable','on');
    set(handles.CONST_TEXT_Resize_factor,'Enable','on');
else
    set(handles.PARA_Preprocessing_ImageResize,'Value',0);
    set(handles.PARA_Preprocessing_ImageResize_factor,'Enable','off');
    set(handles.CONST_TEXT_Resize_factor,'Enable','off');
end
if(handles.Config.PreProcessConfig.Gaussian.On==1)
    set(handles.PARA_Preprocessing_Gaussian,'Value',1);
    set(handles.PARA_Preprocessing_Gaussian_KernelSize,'Enable','on');
    set(handles.CONST_TEXT_Gaussian_KernelSize,'Enable','on');
    set(handles.PARA_Preprocessing_Gaussian_Variance,'Enable','on');
    set(handles.CONST_TEXT_Gaussian_Variance,'Enable','on');
else
    set(handles.PARA_Preprocessing_Gaussian,'Value',0);
    set(handles.PARA_Preprocessing_Gaussian_KernelSize,'Enable','off');
    set(handles.CONST_TEXT_Gaussian_KernelSize,'Enable','off');
    set(handles.PARA_Preprocessing_Gaussian_Variance,'Enable','off');
    set(handles.CONST_TEXT_Gaussian_Variance,'Enable','off');
end
% BS & ROI selection
if(strcmp(handles.Config.PreProcessConfig.BackgroundsubtractionMethod,'Static'))
    set(handles.PARA_Preprocessing_BackgroundMethod_Const,'Value',1);
else
    set(handles.PARA_Preprocessing_BackgroundMethod_Moving,'Value',1);
end
if(strcmp(handles.Config.PreProcessConfig.ActivateROI,'Off'))
    set(handles.PARA_Preprocessing_FixedBoundary,'Value',1);
else
    set(handles.PARA_Preprocessing_ROI_Select,'Value',1);
end
% ROI
set(handles.PARA_Preprocessing_FixedBoundary, 'Enable','off');
set(handles.PARA_Preprocessing_ROI_Select, 'Enable','off');
set(handles.PARA_Preprocessing_FIXBoundarySize,'Enable','off');
% Present Default values
set(handles.PARA_Preprocessing_Background_NumofFrames,'String',num2str(handles.Config.PreProcessConfig.Backgroundframes));
set(handles.PARA_Preprocessing_ImageResize_factor,'String',num2str(handles.Config.PreProcessConfig.Resize.Num));
set(handles.PARA_Preprocessing_Gaussian_KernelSize,'String',num2str(handles.Config.PreProcessConfig.Gaussian.KernelSize));
set(handles.PARA_Preprocessing_Gaussian_Variance,'String',num2str(handles.Config.PreProcessConfig.Gaussian.Variance));
set(handles.PARA_Preprocessing_FIXBoundarySize,'String',handles.Config.PreProcessConfig.BoundaryEdge);
%% Detection

if(strcmp(handles.Config.DetectionConfig.Method.Name,'Manual'))
    % Update Para
    set(handles.SelectionButton_Detection_Manual,'Value',1);
    set(handles.SelectionButton_Detection_ITCiD,'Value',0);
    handles.DHMOperator.TrackingConfig.NN.LocalDetection=1;
    % Update GUI
    handles.MethodGroup.SelectedTab=handles.MethodGroup_Tab_Manual;
elseif(strcmp(handles.Config.DetectionConfig.Method.Name,'ITTrans'))
    % Update Para
    set(handles.SelectionButton_Detection_Manual,'Value',0);
    set(handles.SelectionButton_Detection_ITCiD,'Value',1);
    handles.DHMOperator.TrackingConfig.NN.LocalDetection=0;
    % Update GUI
    handles.MethodGroup.SelectedTab=handles.MethodGroup_Tab_ITs;
else
    handles.DHMOperator.TrackingConfig.NN.LocalDetection=0;
    % Update GUI
    handles.MethodGroup.SelectedTab=handles.MethodGroup_Tab_Blob;
end
% Present Default values
% ITs
set(handles.PARA_Detection_ITCiD_ScaleNum,'String',num2str(handles.Config.DetectionConfig.Method.ITTrans.ScaleNum));
set(handles.PARA_Detection_ITThreshold,'String',num2str(handles.Config.DetectionConfig.Method.ITTrans.ITThresh));
set(handles.PARA_Detection_ITMinVotes,'String',num2str(handles.Config.DetectionConfig.Method.ITTrans.MinVotes));
set(handles.PARA_Detection_Iterations,'String',num2str(handles.Config.DetectionConfig.Method.ITTrans.Iteration));
set(handles.PARA_Detection_CannyEdgeThreshHighMultiple,'String',num2str(handles.Config.DetectionConfig.Method.EdgeThresh));
set(handles.PARA_Detection_ITCiD_LineLength,'String',num2str(handles.Config.DetectionConfig.Method.ITTrans.LineLength));
set(handles.PARA_Detection_ITCiD_MappingSize,'String',num2str(handles.Config.DetectionConfig.Method.ITTrans.MappingRadius));
% Blob
set(handles.PARA_BlobDetection_MinSize,'String',num2str(handles.Config.DetectionConfig.Method.MinSize));
set(handles.PARA_BlobDetection_MaxSize,'String',num2str(handles.Config.DetectionConfig.Method.MaxSize));
set(handles.PARA_BlobDetection_MorphKernelSize,'String',num2str(handles.Config.DetectionConfig.Method.MorphSize));
set(handles.PARA_BlobDetection_IntensityMaskThresholdValue,'String',num2str(handles.Config.DetectionConfig.Method.BinaryMaskLevel));
%% Tracking
    % Update Para
if( handles.Config.TrackingConfig.NN.LocalDetection==1)
    set(handles.SelectionButton_Tracking_NN,'Enable','off');
    set(handles.SelectionButton_Tracking_NN_local,'Value',1);
    set(handles.SelectionButton_Tracking_NN,'Value',0);
else
    set(handles.SelectionButton_Tracking_NN,'Enable','on');
    set(handles.SelectionButton_Tracking_NN_local,'Value',0);
    set(handles.SelectionButton_Tracking_NN,'Value',1);
end
if(handles.Config.TrackingConfig.FixedTemplate==1)
    set(handles.PARA_Tracking_FixedTemplateSize,'Value',1);
    set(handles.PARA_Tracking_TemplateSizeNum,'Enable','on');
else
    set(handles.PARA_Tracking_FixedTemplateSize,'Value',0);
    set(handles.PARA_Tracking_TemplateSizeNum,'Enable','off');
end
if(strcmp(handles.Config.TrackingConfig.NN.TrackingROI,'On'))
    set(handles.PARA_Tracking_BoundaryROI,'Value',1);
else
    set(handles.PARA_Tracking_BoundaryROI,'Value',0);
end
% Present Default values
set(handles.PARA_Tracking_TemplateSizeNum,'String',num2str(handles.Config.TrackingConfig.FixedTemplateSize));
set(handles.PARA_Tracking_MaxDisplacement,'String',num2str(handles.Config.TrackingConfig.NN.MaxDisplacement));
%% Refinement
if(handles.Config.RefinementConfig.Resample.Active==1)
    set(handles.PARA_Refinement_Resampling,'Value',1);
    set(handles.PARA_Resample_Sector,'Enable','on');
    set(handles.PARA_Resample_Circular,'Enable','on');
else
    set(handles.PARA_Refinement_Resampling,'Value',0);
end

if(strcmp(handles.Config.RefinementConfig.Resample.Pattern,'Sector'))
    set(handles.PARA_Resample_Sector,'Value',1);
    set(handles.PARA_Resample_Circular,'Value',0);
else
    set(handles.PARA_Resample_Sector,'Value',0);
    set(handles.PARA_Resample_Circular,'Value',1);
end

if(handles.Config.RefinementConfig.RefineCenter.Active.XCORR==1)
    set(handles.PARA_Refinement_Xcorr,'Value',1);
    set(handles.PARA_Refinement_XcorrMedianBackground,'Enable','on');
else
    set(handles.PARA_Refinement_Xcorr,'Value',0);
    set(handles.PARA_Refinement_XcorrMedianBackground,'Enable','off');
end

if(handles.Config.RefinementConfig.RefineCenter.XCorr.MedianFilter==1)
    set(handles.PARA_Refinement_XcorrMedianBackground,'Value',1);
else
    set(handles.PARA_Refinement_XcorrMedianBackground,'Value',0);
end

%% Reconstruction
if(handles.Config.ReconstructConfig.Active==0)
    set(handles.PARA_Reconstruction_Enable,'Value',0);
    set(handles.SelectionButton_Reconstruction_1D,'Enable','off');
    set(handles.SelectionButton_Reconstruction_1DDecov,'Enable','off');
    set(handles.SelectionButton_Reconstruction_2D,'Enable','off');
    set(handles.PARA_Reconstruction_TemplateMargin,'Enable','off');
    set(handles.PARA_Reconstruciton_TemplateSize,'Enable','off');
    set(handles.PARA_Reconstruction_ParaMask,'Enable','off');
    set(handles.PARA_Reconstruction_StepSize,'Enable','off');
    set(handles.PARA_Reconstruction_InitStep,'Enable','off');
    set(handles.PARA_Reconstruction_EndStep,'Enable','off');
else
    set(handles.PARA_Reconstruction_Enable,'Value',1);
    set(handles.SelectionButton_Reconstruction_1D,'Enable','on');
    set(handles.SelectionButton_Reconstruction_1DDecov,'Enable','off');
    set(handles.SelectionButton_Reconstruction_2D,'Enable','on');
    
    set(handles.PARA_Reconstruction_TemplateMargin,'Enable','on');
    set(handles.PARA_Reconstruciton_TemplateSize,'Enable','on');
    if(strcmp(handles.Config.ReconstructConfig.Method,'1D'))
        set(handles.PARA_Reconstruction_ParaMask,'Enable','on');
    elseif(strcmp(handles.Config.ReconstructConfig.Method,'1DDecov'))
        set(handles.PARA_Reconstruction_ParaMask,'Enable','on');
    else
        set(handles.PARA_Reconstruction_ParaMask,'Enable','off');
    end
    set(handles.PARA_Reconstruction_StepSize,'Enable','on');
    set(handles.PARA_Reconstruction_InitStep,'Enable','on');
    set(handles.PARA_Reconstruction_EndStep,'Enable','on');
    set(handles.PARA_Reconstruction_Wavelength,'Enable','on');
    set(handles.PARA_Reconstruction_RefractiveIndex,'Enable','on');
    set(handles.PARA_Reconstruction_PixelSpacing,'Enable','on');
end

if(strcmp(handles.Config.ReconstructConfig.Method,'1D'))
    set(handles.SelectionButton_Reconstruction_1D,'Value',1);
else
    set(handles.SelectionButton_Reconstruction_1D,'Value',0);
end
if(strcmp(handles.Config.ReconstructConfig.Method,'1DDecov'))
    set(handles.SelectionButton_Reconstruction_1DDecov,'Value',1);
else
    set(handles.SelectionButton_Reconstruction_1DDecov,'Value',0);
end
if(strcmp(handles.Config.ReconstructConfig.Method,'2D'))
    set(handles.SelectionButton_Reconstruction_2D,'Value',1);
else
    set(handles.SelectionButton_Reconstruction_2D,'Value',0);
end

set(handles.PARA_Reconstruction_TemplateMargin,'String',num2str(handles.Config.ReconstructConfig.Basic.TemplateResize));
set(handles.PARA_Reconstruciton_TemplateSize,'String',num2str(handles.Config.ReconstructConfig.Basic.ImageResize));
set(handles.PARA_Reconstruction_ParaMask,'String',num2str(handles.Config.ReconstructConfig.Basic.ParaxialMask));
set(handles.PARA_Reconstruction_StepSize,'String',num2str(handles.Config.ReconstructConfig.Basic.StepSize));
set(handles.PARA_Reconstruction_InitStep,'String',num2str(handles.Config.ReconstructConfig.Basic.StartStep*handles.Config.ReconstructConfig.Basic.Lambda*1e6,'%10.2f'));
set(handles.PARA_Reconstruction_EndStep,'String',num2str(handles.Config.ReconstructConfig.Basic.StopStep*handles.Config.ReconstructConfig.Basic.Lambda*1e6,'%10.2f'));
set(handles.PARA_Reconstruction_Wavelength,'String',num2str(handles.Config.ReconstructConfig.Basic.Wavelength*1e9));
set(handles.PARA_Reconstruction_RefractiveIndex,'String',num2str(handles.Config.ReconstructConfig.Basic.RefractiveIndex));
set(handles.PARA_Reconstruction_PixelSpacing,'String',num2str(handles.Config.ReconstructConfig.Basic.PixelSpacing*1e9));
set(handles.PARA_Reconstruction_StepResolution,'String',num2str(handles.Config.ReconstructConfig.Basic.StepSize*handles.Config.ReconstructConfig.Basic.Lambda*1e6,'%10.2f'));
set(handles.PARA_Reconstruction_NumofSteps,'String',num2str((handles.Config.ReconstructConfig.Basic.StopStep-handles.Config.ReconstructConfig.Basic.StartStep+1)/handles.Config.ReconstructConfig.Basic.StepSize,'%10.0f'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Data presentation
if(handles.Config.OutputConfig.WriteFrame==1)
    set(handles.PARA_DATA_SaveTrackingImages,'Value',1);
else
    set(handles.PARA_DATA_SaveTrackingImages,'Value',0);
end
if(handles.Config.OutputConfig.PresentTrack==1)
    set(handles.PARA_DATA_PresentTrackingImages,'Value',1);
else
    set(handles.PARA_DATA_PresentTrackingImages,'Value',0);
end
if(handles.Config.OutputConfig.PresentReconstruction==1)
    set(handles.PARA_DATA_PresentReconstruction,'Value',1);
else
    set(handles.PARA_DATA_PresentReconstruction,'Value',0);
end
disp('Ready');
function varargout = UMUTracker_OutputFcn(~, ~, handles)
varargout{1} = handles.output;

% -------------------------------FileIn1-----------------------------------
% -- Menu --
function Menu_FileIO_Callback(~, ~, ~)
function Menu_File_LoadVideo_Callback(hObject, ~, handles)
% This function initalized background images and load videos
[hObject,handles]=LoadFiles(hObject,handles);
guidata(hObject, handles);
% -------------------------------FileIn2-----------------------------------
% -- Buttom  --
function Button_LoadVideo_Callback(hObject, ~, handles)
% hObject    handle to Button_LoadVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles]=LoadFiles(hObject,handles);
guidata(hObject, handles);
% --------------------------------Load-------------------------------------
%
% --               Load a video and enable buttoms / functions           --
function [hObject,handles]=LoadFiles(hObject,handles)
handles.DHMOperator.ResetBeforeLoad;
handles.DataSource.LoadVideo();
if(handles.DataSource.Readable==1)
    % Enable buttoms
    
    set(handles.Button_StartDHM,'Enable','on');
    Func_ShowText(handles.Axes_ProcessBar,'Ready to Start');
    
    set(handles.Button_CheckDetection,'Enable','on');
    set(handles.PARA_Preprocessing_FixedBoundary, 'Enable','on');
    set(handles.PARA_Preprocessing_ROI_Select, 'Enable','on');
    set(handles.PARA_Detection_CannyEdgeThreshHighMultiple,'Enable','on');
    
    if(2*handles.DHMOperator.TrackingConfig.FixedTemplateSize+1>min(handles.DataSource.Width,handles.DataSource.Height))
        handles.DHMOperator.TrackingConfig.FixedTemplateSize=floor(min(handles.DataSource.Width,handles.DataSource.Height)/2);
    end
    %% Check ROI
    % Check ROI parameters
    if(strcmp(handles.DHMOperator.PreProcessConfig.ActivateROI,'On'))
        set(handles.PARA_Preprocessing_FIXBoundarySize,'Enable','off');
    else
        BRegion=handles.DHMOperator.PreProcessConfig.BoundaryEdge;
        % Update ROI Parameters
        handles.DHMOperator.PreProcessConfig.ROI=[1+ BRegion 1+BRegion handles.DataSource.Width-2*BRegion-1 handles.DataSource.Height-2*BRegion-1];
        set(handles.PARA_Preprocessing_FIXBoundarySize,'Enable','on');
    end
    % Update ROI
    set(handles.TEXT_ROISize,'String',...
        strcat('W:',num2str(handles.DHMOperator.PreProcessConfig.ROI(1)),'- ',...
        num2str(handles.DHMOperator.PreProcessConfig.ROI(1)+handles.DHMOperator.PreProcessConfig.ROI(3)),',',...
        'H:',num2str(handles.DHMOperator.PreProcessConfig.ROI(2)),'-',...
        num2str(handles.DHMOperator.PreProcessConfig.ROI(2)+handles.DHMOperator.PreProcessConfig.ROI(4))));
    
    set(handles.TEXT_PARA_InputPath,'String',handles.DataSource.path);
    set(handles.TEXT_PARA_InputFileName,'String',handles.DataSource.name);
    set(handles.TEXT_ImageSize,'String',...
            strcat('W:',num2str(handles.DataSource.Width),',H:',num2str(handles.DataSource.Height)));
    %% BackgroundSub
    if(strcmp(handles.DHMOperator.PreProcessConfig.Backgroundsubtraction,'On')|| strcmp(handles.DHMOperator.PreProcessConfig.Backgroundnorm,'On'))
        set(handles.PARA_Preprocessing_BackgroundMethod_Const,'Enable','on');
        set(handles.PARA_Preprocessing_BackgroundMethod_Moving,'Enable','on');
        handles=BackgroundUpdate(handles,hObject);
    end % Backsub
    
    % Present video frame (1st frame)
    updateImageFirstFrame(handles);
    Update_slider_FirstFrame(handles,0);
    Update_EditFirstFrameNum(handles,1);
    Update_listbox_VideoInfo(handles);
else
    % Enable buttoms
    set(handles.Button_StartDHM,'Enable','off');
    set(handles.Button_CheckDetection,'Enable','off');
    set(handles.PARA_Preprocessing_FixedBoundary, 'Enable','off');
    set(handles.PARA_Preprocessing_ROI_Select, 'Enable','off');
    set(handles.PARA_Preprocessing_FIXBoundarySize,'Enable','off');
    set(handles.PARA_Preprocessing_BackgroundMethod_Const,'Enable','off');
    set(handles.PARA_Preprocessing_BackgroundMethod_Moving,'Enable','off');
    set(handles.PARA_Detection_CannyEdgeThreshHighMultiple,'Enable','off');
end

function TEXT_PARA_InputPath_Callback(~, ~, ~)
function TEXT_PARA_InputPath_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function TEXT_PARA_InputFileName_Callback(~, ~, ~)
function TEXT_PARA_InputFileName_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%% --------------------- Start the process -------------------------
%
%                               -- Main --                                %
function Button_StartDHM_Callback(hObject, eventdata, handles)
% Update Bottons
set(handles.Button_StartDHM,'Enable','off');
set(handles.Button_StopDHM,'Enable','on');
set(handles.Button_Continue_Pause_DHM,'Enable','on');
guidata(hObject,handles);  %Update the GUI data
% UMUTracker
StartingFrame=handles.DataSource.FrameNumber-1;
handles.DHMOperator.BacksubCounter=0;
while handles.DataSource.VideoSrc.CurrentTime<handles.DataSource.VideoSrc.Duration
    Func_Processbar(handles.Axes_ProcessBar,handles.DataSource.FrameNumber/handles.DataSource.TotalFrames);
    % Get new frame
    handles.DataSource.GetFrame;
    % Preprocess
    handles.DHMOperator.Preprocess(handles.DataSource.Im);
    % BackgroundSubtraction
    if(strcmp(handles.DHMOperator.PreProcessConfig.Backgroundsubtraction,'On') && strcmp(handles.DHMOperator.PreProcessConfig.Backgroundnorm,'Off'))
        if(strcmp(handles.DHMOperator.PreProcessConfig.BackgroundsubtractionMethod,'Static'))
            handles.DHMOperator.BackgroundSubStatic(handles.DHMOperator.Image);
        else
            % Start processing at [obj.PreProcessConfig.Backgroundframes+1]th
            % Frame
            if(handles.DHMOperator.BacksubReady==0)
                handles.DHMOperator.BackgroundMovingAve(handles.DHMOperator.Image);
                continue;
            end
            handles.DHMOperator.BackgroundMovingAve(handles.DHMOperator.Image);
            handles.DHMOperator.IntensitySub(handles.DHMOperator.Image);
        end
    elseif(strcmp(handles.DHMOperator.PreProcessConfig.Backgroundsubtraction,'Off') && strcmp(handles.DHMOperator.PreProcessConfig.Backgroundnorm,'On'))
        if(strcmp(handles.DHMOperator.PreProcessConfig.BackgroundsubtractionMethod,'Static'))
            handles.DHMOperator.BackgroundHoloStatic(handles.DHMOperator.Image);
        else
            % Start processing at [obj.PreProcessConfig.Backgroundframes+1]th
            % Frame
            if(handles.DHMOperator.BacksubReady==0)
                handles.DHMOperator.BackgroundMovingAve(handles.DHMOperator.Image);
                continue;
            end
            handles.DHMOperator.BackgroundMovingAve(handles.DHMOperator.Image);
            handles.DHMOperator.IntensityNorm(handles.DHMOperator.Image);
        end
    end
    % Detection
    handles.DHMOperator.Detect(handles.DHMOperator.Image);
    % Tracking
    handles.DHMOperator.Track(handles.DHMOperator.Image,...
                              handles.DHMOperator.Detection);
    if(handles.DHMOperator.ReconstructConfig.Active==1)
        inc_samples=0;
        % Refine centers
        for i=1:length(handles.DHMOperator.Tracks)
            if(~size(handles.DHMOperator.Tracks(i).Template,1)==0)
                InstantVelocityVector=handles.DHMOperator.Tracks(i).Centroid-handles.DHMOperator.Tracks(i).LastVisible;
                Direction=atan2(InstantVelocityVector(2),InstantVelocityVector(1));
                handles.DHMOperator.Refine(handles.DHMOperator.Tracks(i).Template,...
                    handles.DHMOperator.TrackingConfig.FixedTemplate,...
                    handles.DHMOperator.Tracks(i).TemplateCenter,...
                    Direction);
                Pattern1D{i}=handles.DHMOperator.DiffractionPattern1D;
                Pattern2D{i}=handles.DHMOperator.DiffractionPattern;
                inc_samples=inc_samples+1;
            end
        end
        Config=handles.DHMOperator.ReconstructConfig.Basic;
        GPUActive=handles.DHMOperator.GPUConfig.Active;
        ZPos=zeros(1,length(handles.DHMOperator.Tracks));
        % Reconstruction
        if(inc_samples~=0)
            if(inc_samples>=4 || handles.DHMOperator.CPUConfig.ParForActive==1)
                if(strcmpi(handles.DHMOperator.ReconstructConfig.Method,'1D'))
                    parfor ic=1:inc_samples
                        [~,ZPos(ic)]=Acc_Reconstruction1D(Pattern1D{ic},Config,GPUActive);
                    end      
                else
                    parfor ic=1:inc_samples
                        [~,ZPos(ic)]=Acc_Reconstruction2D(Pattern2D{ic},Config,GPUActive);
                    end
                end
            else
                if(strcmpi(handles.DHMOperator.ReconstructConfig.Method,'1D'))
                    for ic=1:inc_samples
                        [handles.DHMOperator.ReconstructedCenterIntensityZ,ZPos(ic)]=Acc_Reconstruction1D(Pattern1D{ic},Config,GPUActive);
                    end      
                else
                    for ic=1:inc_samples
                        [handles.DHMOperator.ReconstructedCenterIntensityZ,ZPos(ic)]=Acc_Reconstruction2D(Pattern2D{ic},Config,GPUActive);
                    end
                end
            end
            for ic=1:inc_samples
                handles.DHMOperator.GetZ(ZPos(ic),ic);
                if(handles.DHMOperator.Tracks(ic).ZPos==0)
                    handles.DHMOperator.Tracks(ic).Visibility=0;
                end
            end
        end
    end
    if(handles.DataCollector.DataConfig.PresentTrack==0)
       pause(0.005); % 
    end
    % Data analysis
    handles.DataCollector.Collect(handles.DHMOperator.Tracks,...
                                  handles.DHMOperator.TrackingConfig,...
                                  handles.DHMOperator.ReconstructConfig.Basic.PixelSpacing/handles.DHMOperator.PreProcessConfig.Resize.Num,...
                                  handles.DataSource.FrameNumber,...
                                  handles.DHMOperator.Detection);
    handles.DataCollector.Present(handles.DHMOperator,handles.DataSource.FrameNumber);
    handles.DataCollector.SaveData(handles.DHMOperator,handles.DataSource.FrameNumber,handles.DHMOperator.Detection); %TEXT FILES WRITTEN
    % Interrupts
    userData = get(handles.output, 'UserData');
    if userData.stop == true
        userData.stop = false; % Reset for next time
        set(handles.figure_UmUTracker,'UserData',userData);
        break;
    end
    if userData.pause == true
        while(userData.pause == true)
            pause(0.1);
            userData = get(handles.output, 'UserData');
        end
    end
end
% Reset Video,Background Detection and Tracking
handles.DataSource.Reset;
handles.DHMOperator.ResetTracks;
handles.DHMOperator.ResetAfterTracking;
handles.DataCollector.ResetPlayer;
handles.DHMOperator.BacksubReady=0;
handles.DHMOperator.BacksubCounter=0;
% Update starting frame
handles.DataSource.GetFrame(StartingFrame);
updateImageFirstFrame(handles);
set(handles.Edit_FirstFrameNum,'String',num2str(StartingFrame));
set(handles.slider_FirstFrame,'value',StartingFrame/handles.DataSource.TotalFrames);
% Update Bottons
set(handles.Button_StartDHM,'Enable','on');
Func_ShowText(handles.Axes_ProcessBar,'Ready to Start');
set(handles.Button_StopDHM,'Enable','off');
set(handles.Button_Continue_Pause_DHM,'Enable','off');
guidata(hObject, handles);
% Stop / Pause / Continue
function Button_StopDHM_Callback(hObject, eventdata, handles)
userData = get(handles.output, 'UserData');
userData.stop = true;
set(handles.output,'UserData',userData);
%
set(handles.Button_StopDHM,'Enable','off');
guidata(hObject, handles);
function Button_Continue_Pause_DHM_Callback(hObject, ~, handles)
userData = get(handles.output, 'UserData');
if(userData.pause==true)
    userData.pause = false;
    set(hObject,'String','Pause');
    set(handles.Button_StopDHM,'Enable','on');
else
    userData.pause = true;
    set(hObject,'String','Continue');
    set(handles.Button_StopDHM,'Enable','off');
end
set(handles.output,'UserData',userData);
%
guidata(hObject, handles);
% --------------------------Preprocessing----------------------------------
function PARA_Preprocessing_IntensityScaling_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Preprocessing_IntensityScaling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CheckValue=get(hObject,'Value');
if(CheckValue==1)
    % UpdateInstance
    handles.DHMOperator.PreProcessConfig.IntensityRescaling='On';
else
    % UpdateInstance
    handles.DHMOperator.PreProcessConfig.IntensityRescaling='Off';
end
handles=BackgroundUpdate(handles,hObject);
guidata(hObject, handles);

function PARA_Preprocessing_ImageResize_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Preprocessing_ImageResize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CheckValue=get(hObject,'Value');
if(CheckValue==1)
    handles.DHMOperator.PreProcessConfig.Resize.On=1;
    
    set(handles.PARA_Preprocessing_ImageResize_factor,'Enable','on')
    set(handles.CONST_TEXT_Resize_factor,'Enable','on')
else
    handles.DHMOperator.PreProcessConfig.Resize.On=0;

    % Update Background 2D
    handles=BackgroundUpdate(handles,hObject);
    
    % ! Restore previous configurations
    handles.DHMOperator.ReconstructConfig.Basic.StopStep=handles.Config.ReconstructConfig.Basic.StopStep;
    handles.DHMOperator.ReconstructConfig.Basic.StartStep=handles.Config.ReconstructConfig.Basic.StartStep;
    handles.DHMOperator.ReconstructConfig.Basic.StepSize=handles.Config.ReconstructConfig.Basic.StepSize;
    handles.DHMOperator.ReconstructConfig.Basic.PixelSpacing=handles.Config.ReconstructConfig.Basic.PixelSpacing;
    
    % Update Interface
    set(handles.PARA_Reconstruction_EndStep,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StopStep));
    set(handles.PARA_Reconstruction_InitStep,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StartStep));
    set(handles.PARA_Reconstruction_StepSize,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StepSize));
    set(handles.PARA_Reconstruction_StepResolution,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StepSize*handles.DHMOperator.ReconstructConfig.Basic.Lambda*1e6,'%10.2f'));
    set(handles.PARA_Reconstruction_NumofSteps,'String',num2str((handles.DHMOperator.ReconstructConfig.Basic.StopStep-handles.DHMOperator.ReconstructConfig.Basic.StartStep+1)/handles.DHMOperator.ReconstructConfig.Basic.StepSize,'%10.0f'));
    set(handles.PARA_Reconstruction_PixelSpacing,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.PixelSpacing*1e9));
    
    % Update Interfaces
    set(handles.PARA_Preprocessing_ImageResize_factor,'Enable','off')
    set(handles.CONST_TEXT_Resize_factor,'Enable','off')
end
handles.DHMOperator.PreProcessConfig.Resize.Num=1;  

set(handles.PARA_Preprocessing_ImageResize_factor,'String',num2str(handles.DHMOperator.PreProcessConfig.Resize.Num));
guidata(hObject, handles);
function PARA_Preprocessing_ImageResize_factor_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Preprocessing_ImageResize_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.PreProcessConfig.Resize.Num));
    guidata(hObject, handles);
    return
end
[ResizeNumber, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.PreProcessConfig.Resize.Num));
    guidata(hObject, handles);
    return
end

% Update Configurations
handles.DHMOperator.PreProcessConfig.Resize.Num=ResizeNumber;
handles=BackgroundUpdate(handles,hObject);

handles.DHMOperator.ReconstructConfig.Basic.StopStep=handles.Config.ReconstructConfig.Basic.StopStep/ResizeNumber;
handles.DHMOperator.ReconstructConfig.Basic.StartStep=handles.Config.ReconstructConfig.Basic.StartStep/ResizeNumber;
handles.DHMOperator.ReconstructConfig.Basic.StepSize=handles.Config.ReconstructConfig.Basic.StepSize/ResizeNumber;
handles.DHMOperator.ReconstructConfig.Basic.PixelSpacing=handles.Config.ReconstructConfig.Basic.PixelSpacing/ResizeNumber;


% Update Interface (Tracking properties)
set(handles.PARA_Reconstruction_EndStep,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StopStep));
set(handles.PARA_Reconstruction_InitStep,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StartStep));
set(handles.PARA_Reconstruction_StepSize,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StepSize));
set(handles.PARA_Reconstruction_StepResolution,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StepSize*handles.DHMOperator.ReconstructConfig.Basic.Lambda*1e6,'%10.2f'));
set(handles.PARA_Reconstruction_NumofSteps,'String',num2str((handles.DHMOperator.ReconstructConfig.Basic.StopStep-handles.DHMOperator.ReconstructConfig.Basic.StartStep+1)/handles.DHMOperator.ReconstructConfig.Basic.StepSize,'%10.0f'));
set(handles.PARA_Reconstruction_PixelSpacing,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.PixelSpacing*1e9));

set(hObject,'String',num2str(handles.DHMOperator.PreProcessConfig.Resize.Num));
guidata(hObject, handles);
function PARA_Preprocessing_ImageResize_factor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Preprocessing_ImageResize_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_Preprocessing_Gaussian_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Preprocessing_Gaussian (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CheckValue=get(hObject,'Value');
if(CheckValue==1)
    % UpdateInstance
    handles.DHMOperator.PreProcessConfig.Gaussian.On=1;
    
    set(handles.PARA_Preprocessing_Gaussian_KernelSize,'Enable','on');
    set(handles.CONST_TEXT_Gaussian_KernelSize,'Enable','on');
    set(handles.PARA_Preprocessing_Gaussian_Variance,'Enable','on');
    set(handles.CONST_TEXT_Gaussian_Variance,'Enable','on');
else
    % UpdateInstance
    handles.DHMOperator.PreProcessConfig.Gaussian.On=0;
    
    set(handles.PARA_Preprocessing_Gaussian_KernelSize,'Enable','off');
    set(handles.CONST_TEXT_Gaussian_KernelSize,'Enable','off');
    set(handles.PARA_Preprocessing_Gaussian_Variance,'Enable','off');
    set(handles.CONST_TEXT_Gaussian_Variance,'Enable','off');
end
set(handles.PARA_Preprocessing_Gaussian_KernelSize,'String',num2str(handles.DHMOperator.PreProcessConfig.Gaussian.KernelSize));
set(handles.PARA_Preprocessing_Gaussian_Variance,'String',num2str(handles.DHMOperator.PreProcessConfig.Gaussian.Variance));
handles=BackgroundUpdate(handles,hObject);
guidata(hObject, handles);
function PARA_Preprocessing_Gaussian_KernelSize_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Preprocessing_Gaussian_KernelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.PreProcessConfig.Gaussian.KernelSize));
    guidata(hObject, handles);
    return
end
[ResizeNumber, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.PreProcessConfig.Gaussian.KernelSize));
    guidata(hObject, handles);
    return
end
handles.DHMOperator.PreProcessConfig.Gaussian.KernelSize=ResizeNumber;
set(hObject,'String',num2str(handles.DHMOperator.PreProcessConfig.Gaussian.KernelSize));
handles=BackgroundUpdate(handles,hObject);
guidata(hObject, handles);
function PARA_Preprocessing_Gaussian_KernelSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Preprocessing_Gaussian_KernelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function PARA_Preprocessing_Gaussian_Variance_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Preprocessing_Gaussian_Variance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.PreProcessConfig.Gaussian.Variance));
    guidata(hObject, handles);
    return
end
[ResizeNumber, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.PreProcessConfig.Gaussian.Variance));
    guidata(hObject, handles);
    return
end
handles.DHMOperator.PreProcessConfig.Gaussian.Variance=ResizeNumber;
set(hObject,'String',num2str(handles.DHMOperator.PreProcessConfig.Gaussian.Variance));
handles=BackgroundUpdate(handles,hObject);
guidata(hObject, handles);
function PARA_Preprocessing_Gaussian_Variance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Preprocessing_Gaussian_Variance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_Preprocessing_ROI_Select_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Preprocessing_ROI_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%ROI
CheckValue=get(hObject,'Value');
if(CheckValue==1)
    set(hObject,'Enable','off');
    guidata(hObject, handles);
    FRAME_WIDTH=handles.DataSource.Width;
    FRAME_HIGHT=handles.DataSource.Height;
    try
        initial_roi=load('LastPosition.txt','-ascii');
        if(initial_roi(1)<1 || initial_roi(1)>=FRAME_WIDTH)
           initial_roi(1)=1; 
        end
        if(initial_roi(2)<1 || initial_roi(2)>=FRAME_HIGHT)
           initial_roi(2)=1; 
        end
        if(initial_roi(1)+initial_roi(3)>FRAME_WIDTH || initial_roi(3)<=0)
           initial_roi(3)=FRAME_WIDTH-initial_roi(1); 
        end
        if(initial_roi(2)+initial_roi(4)>FRAME_HIGHT || initial_roi(4)<=0)
           initial_roi(4)=FRAME_HIGHT-initial_roi(2); 
        end   
    catch
        initial_roi=[1   1  FRAME_WIDTH-1 FRAME_HIGHT-1];
    end
    %
    %StartingFrame=handles.DataSource.FrameNumber;
    %handles.DataSource.GetFrame(StartingFrame);
    Im=handles.DataSource.Im;
    fig=figure('Name','Move and change the Region-of-Interest (Double click to confirm)','NumberTitle','off');
    imshow(Im);
    h = imrect(gca, initial_roi);
    setResizable(h,1)
    position = wait(h); % Double click
    close(fig)

    if(position(1)<1 || position(1)>=FRAME_WIDTH)
        position(1)=1;
    end
    if(position(2)<1 || position(2)>=FRAME_HIGHT)
        position(2)=1;
    end
    if(position(1)+position(3)>FRAME_WIDTH || position(3)<=0)
        position(3)=FRAME_WIDTH-position(1);
    end
    if(position(2)+position(4)>FRAME_HIGHT || position(4)<=0)
        position(4)=FRAME_HIGHT-position(2);
    end

    save('LastPosition.txt','position','-ascii');
    % UpdateInstance
    handles.DHMOperator.PreProcessConfig.ActivateROI='On';
    handles.DHMOperator.PreProcessConfig.ROI=uint32(position);
    % Update Display
     set(handles.TEXT_ROISize,'String',...
        strcat('W:',num2str(handles.DHMOperator.PreProcessConfig.ROI(1)),'- ',...
        num2str(handles.DHMOperator.PreProcessConfig.ROI(1)+handles.DHMOperator.PreProcessConfig.ROI(3)),',',...
        'H:',num2str(handles.DHMOperator.PreProcessConfig.ROI(2)),'-',...
        num2str(handles.DHMOperator.PreProcessConfig.ROI(2)+handles.DHMOperator.PreProcessConfig.ROI(4))));
    % Reset video
    handles=BackgroundUpdate(handles,hObject);
    % Update GUI
    set(handles.PARA_Preprocessing_FIXBoundarySize,'Enable','off');
    set(hObject,'Enable','on');
end
guidata(hObject, handles);

function PARA_Preprocessing_FixedBoundary_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Preprocessing_FixedBoundary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% UpdateParametersSetting
CheckValue=get(hObject,'Value');
if(CheckValue==1)
    set(hObject,'Enable','off');
    guidata(hObject, handles);
    handles.DHMOperator.PreProcessConfig.ActivateROI='Off';
    
    BRegion=handles.DHMOperator.PreProcessConfig.BoundaryEdge;
    handles.DHMOperator.PreProcessConfig.ROI=[1+ BRegion 1+BRegion handles.DataSource.Width-2*BRegion-1 handles.DataSource.Height-2*BRegion-1];
    set(handles.TEXT_ROISize,'String',...
        strcat('W:',num2str(handles.DHMOperator.PreProcessConfig.ROI(1)),'- ',...
        num2str(handles.DHMOperator.PreProcessConfig.ROI(1)+handles.DHMOperator.PreProcessConfig.ROI(3)),',',...
        'H:',num2str(handles.DHMOperator.PreProcessConfig.ROI(2)),'-',...
        num2str(handles.DHMOperator.PreProcessConfig.ROI(2)+handles.DHMOperator.PreProcessConfig.ROI(4))));
    % Update GUI
    set(handles.PARA_Preprocessing_FIXBoundarySize,'Enable','on');
    % Update Background
    handles=BackgroundUpdate(handles,hObject);
    set(hObject,'Enable','on');
end
% Update GUI
guidata(hObject, handles);
function PARA_Preprocessing_FIXBoundarySize_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Preprocessing_FIXBoundarySize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.PreProcessConfig.BoundaryEdge));
    guidata(hObject, handles);
    return
end
[BRegion, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.PreProcessConfig.BoundaryEdge));
    guidata(hObject, handles);
    return
end
handles.DHMOperator.PreProcessConfig.BoundaryEdge=BRegion;
% Update ROI
handles.DHMOperator.PreProcessConfig.ROI=[1+ BRegion 1+BRegion handles.DataSource.Width-2*BRegion-1 handles.DataSource.Height-2*BRegion-1];
% Update Background
handles=BackgroundUpdate(handles,hObject);
% Update GUI
 set(handles.TEXT_ROISize,'String',...
        strcat('W:',num2str(handles.DHMOperator.PreProcessConfig.ROI(1)),'- ',...
        num2str(handles.DHMOperator.PreProcessConfig.ROI(1)+handles.DHMOperator.PreProcessConfig.ROI(3)),',',...
        'H:',num2str(handles.DHMOperator.PreProcessConfig.ROI(2)),'-',...
        num2str(handles.DHMOperator.PreProcessConfig.ROI(2)+handles.DHMOperator.PreProcessConfig.ROI(4))));


set(hObject,'String',num2str(handles.DHMOperator.PreProcessConfig.BoundaryEdge));
guidata(hObject, handles);
function PARA_Preprocessing_FIXBoundarySize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Preprocessing_FIXBoundarySize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --------------------------------Background Norm--------------------------
function PARA_Preprocessing_Background_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Preprocessing_Background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CheckValue=get(hObject,'Value');
if(CheckValue==1)
    % UpdateInstance
    handles.DHMOperator.PreProcessConfig.Backgroundnorm='On';
    handles.DHMOperator.PreProcessConfig.Backgroundsubtraction='Off';
    set(handles.Check_BackgroundSub,'Value',0);
    set(handles.PARA_Preprocessing_Background_NumofFrames,'Enable','on');
    set(handles.CONST_TEXT_Preprocessing_Background,'Enable','on');
    set(handles.PARA_Preprocessing_BackgroundMethod_Const,'Enable','on');
    set(handles.PARA_Preprocessing_BackgroundMethod_Moving,'Enable','on');
    handles=BackgroundUpdate(handles,hObject);
else
    % UpdateInstance
    handles.DHMOperator.PreProcessConfig.Backgroundnorm='Off';
    set(handles.PARA_Preprocessing_Background_NumofFrames,'Enable','off');
    set(handles.CONST_TEXT_Preprocessing_Background,'Enable','off');
    set(handles.PARA_Preprocessing_BackgroundMethod_Const,'Enable','off');
    set(handles.PARA_Preprocessing_BackgroundMethod_Moving,'Enable','off');
    updateImageFirstFrame(handles);
end
set(handles.PARA_Preprocessing_Background_NumofFrames,'String',num2str(handles.DHMOperator.PreProcessConfig.Backgroundframes));
guidata(hObject, handles);
function Check_BackgroundSub_Callback(hObject, eventdata, handles)
CheckValue=get(hObject,'Value');
if(CheckValue==1)
    % UpdateInstance
    handles.DHMOperator.PreProcessConfig.Backgroundnorm='Off';
    handles.DHMOperator.PreProcessConfig.Backgroundsubtraction='On';
    set(handles.PARA_Preprocessing_Background,'Value',0);
    set(handles.PARA_Preprocessing_Background_NumofFrames,'Enable','on');
    set(handles.CONST_TEXT_Preprocessing_Background,'Enable','on');
    set(handles.PARA_Preprocessing_BackgroundMethod_Const,'Enable','on');
    set(handles.PARA_Preprocessing_BackgroundMethod_Moving,'Enable','on');
    handles=BackgroundUpdate(handles,hObject);
else
    % UpdateInstance
    handles.DHMOperator.PreProcessConfig.Backgroundsubtraction='Off';
    set(handles.PARA_Preprocessing_Background_NumofFrames,'Enable','off');
    set(handles.CONST_TEXT_Preprocessing_Background,'Enable','off');
    set(handles.PARA_Preprocessing_BackgroundMethod_Const,'Enable','off');
    set(handles.PARA_Preprocessing_BackgroundMethod_Moving,'Enable','off');
    updateImageFirstFrame(handles);
end
set(handles.PARA_Preprocessing_Background_NumofFrames,'String',num2str(handles.DHMOperator.PreProcessConfig.Backgroundframes));
guidata(hObject, handles);
function PARA_Preprocessing_Background_NumofFrames_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Preprocessing_Background_NumofFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.PreProcessConfig.Backgroundframes));
    guidata(hObject, handles);
    return
end
[BSFrameNumber, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.PreProcessConfig.Backgroundframes));
    guidata(hObject, handles);
    return
end
if(BSFrameNumber>=1 && BSFrameNumber<=handles.DataSource.TotalFrames)
    handles.DHMOperator.PreProcessConfig.Backgroundframes=BSFrameNumber;
elseif(BSFrameNumber==0)
    handles.DHMOperator.PreProcessConfig.Backgroundframes=handles.DataSource.TotalFrames;
else
    set(hObject,'String',num2str(handles.DHMOperator.PreProcessConfig.Backgroundframes));
    return
end
set(hObject,'String',num2str(handles.DHMOperator.PreProcessConfig.Backgroundframes));
if(strcmp(handles.DHMOperator.PreProcessConfig.BackgroundsubtractionMethod,'Static'))
    handles=BackgroundUpdate(handles,hObject);
    set(handles.PARA_Preprocessing_BackgroundMethod_Const,'Value',1);
else
    updateImageFirstFrame(handles);
    set(handles.PARA_Preprocessing_BackgroundMethod_Moving,'Value',1);
end
guidata(hObject, handles);
function PARA_Preprocessing_Background_NumofFrames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Preprocessing_Background_NumofFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_Preprocessing_BackgroundMethod_Const_Callback(hObject, eventdata, handles)
toggelValue=get(hObject,'Value');
if(toggelValue==1)
    set(hObject,'Enable','off');
    guidata(hObject, handles);
    % UpdateInstance
    handles.DHMOperator.PreProcessConfig.BackgroundsubtractionMethod='Static';
    % Update Background
    handles=BackgroundUpdate(handles,hObject);
    set(hObject,'Enable','on');
end
handles.DataSource.FrameNumber
guidata(hObject, handles);
function PARA_Preprocessing_BackgroundMethod_Moving_Callback(hObject, eventdata, handles)
toggelValue=get(hObject,'Value');
if(toggelValue==1)
    set(hObject,'Enable','off');
    guidata(hObject, handles);
    % UpdateInstance
    handles.DHMOperator.PreProcessConfig.BackgroundsubtractionMethod='Moving';
    updateImageFirstFrame(handles);
    set(hObject,'Enable','on');
end
handles.DataSource.FrameNumber
guidata(hObject, handles);
function handles=BackgroundUpdate(handles,hObject)
if(handles.DataSource.Readable==1 && (strcmp(handles.DHMOperator.PreProcessConfig.Backgroundsubtraction,'On') || strcmp(handles.DHMOperator.PreProcessConfig.Backgroundnorm,'On')))
        h_break=0;
        h_wait = waitbar(0,'Please wait for calulating background image...',...
            'Name','Static Video Background',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        setappdata(h_wait,'canceling',0)
        %% Buttons
        set(handles.Button_StartDHM,'Enable','off');
        set(handles.Button_CheckDetection,'Enable','off');
        set(handles.PARA_Preprocessing_BackgroundMethod_Const,'Enable','off');
        set(handles.PARA_Preprocessing_BackgroundMethod_Moving,'Enable','off');
        guidata(hObject, handles);
        %%
        handles.DataSource.FrameNumber
        StartingFrame=handles.DataSource.FrameNumber-1;
        handles.DHMOperator.Preprocess(handles.DataSource.Im);
        BackgroundImageFirst=handles.DHMOperator.Image;
        backgroundImtemp=zeros([size(BackgroundImageFirst) handles.DHMOperator.PreProcessConfig.Backgroundframes]);
        backgroundImtemp(:,:,1)=BackgroundImageFirst;
        for i=2:handles.DHMOperator.PreProcessConfig.Backgroundframes
            waitbar(i/handles.DHMOperator.PreProcessConfig.Backgroundframes);
            if getappdata(h_wait,'canceling')
                h_break=1;
                break
            end
            handles.DataSource.GetFrame;
            handles.DHMOperator.Preprocess(handles.DataSource.Im);
            backgroundImtemp(:,:,i)=handles.DHMOperator.Image;
        end
        BackgroundImage=mean(backgroundImtemp,3);
        delete(h_wait);
        guidata(hObject, handles);
        handles.DataSource.GetFrame(StartingFrame);
        if(h_break==0)
            %BackgroundImageFiltered=medfilt2(BackgroundImage,[5 5],'symmetric');
            BackgroundHologram=BackgroundImage;
            BackgroundHologram(BackgroundHologram==0)=0.001;% for numerical stability
            %%
            handles.DHMOperator.PreProcessConfig.BackgroundImage=BackgroundImage;
            handles.DHMOperator.PreProcessConfig.BackgroundHologram=BackgroundHologram;
            %% Buttons
            set(handles.PARA_Preprocessing_BackgroundMethod_Const,'Enable','on');
            set(handles.PARA_Preprocessing_BackgroundMethod_Moving,'Enable','on');
            set(handles.PARA_Preprocessing_BackgroundMethod_Const,'Value',1);
        else
            %% Buttons
            set(handles.PARA_Preprocessing_BackgroundMethod_Const,'Enable','off');
            set(handles.PARA_Preprocessing_BackgroundMethod_Moving,'Enable','off');
            set(handles.CONST_TEXT_Preprocessing_Background,'Enable','off');
            set(handles.PARA_Preprocessing_Background_NumofFrames,'Enable','off');
            % Set Default Background Values
            handles.DHMOperator.PreProcessConfig.Backgroundframes=1;
            handles.DHMOperator.PreProcessConfig.BackgroundsubtractionMethod='Static';
            set(handles.PARA_Preprocessing_Background_NumofFrames,'String',num2str(handles.DHMOperator.PreProcessConfig.Backgroundframes));
            handles.DHMOperator.PreProcessConfig.Backgroundsubtraction='Off';
            handles.DHMOperator.PreProcessConfig.Backgroundnorm='Off';
            set(handles.PARA_Preprocessing_Background,'Value',0);
            set(handles.Check_BackgroundSub,'Value',0);
            set(handles.PARA_Preprocessing_BackgroundMethod_Moving,'Value',1);
        end
        set(handles.Button_StartDHM,'Enable','on');
        Func_ShowText(handles.Axes_ProcessBar,'Ready to Start');
        updateImageFirstFrame(handles);
        set(handles.Button_CheckDetection,'Enable','on');
end
% -------------------------- Edge Detection -------------------------------
% --                     Select Detection Method                         --
function MethodGroup_Tab_Manual_Callback(hObject, ~, handles)
    % UpdateInstance
    handles.DHMOperator.DetectionConfig.Method.Name='Manual';
    % Update Para
    handles.DHMOperator.TrackingConfig.NN.LocalDetection=1;
    handles.DHMOperator.DetectionConfig.Method.ManualSelection=1;
    % Update GUI
    handles=UpdateITTransformOff(handles); 
guidata(hObject, handles);
function MethodGroup_Tab_Blob_Callback(hObject, ~, handles)
    % UpdateInstance
    handles.DHMOperator.DetectionConfig.Method.Name='Cell';   
    % Update Para
    handles=UpdateITTransformOn(handles);
    handles.DHMOperator.TrackingConfig.NN.LocalDetection=0;
    handles.DHMOperator.DetectionConfig.Method.ManualSelection=0;
guidata(hObject, handles);
function MethodGroup_Tab_ITs_Callback(hObject, ~, handles)
    % UpdateInstance
    handles.DHMOperator.DetectionConfig.Method.Name='ITTrans';    
    % Update Para
    handles.DHMOperator.TrackingConfig.NN.LocalDetection=0;
    handles.DHMOperator.DetectionConfig.Method.ManualSelection=0;
    % Update GUI
    handles=UpdateITTransformOn(handles);
    set(handles.SelectionButton_Tracking_NN_local,'Value',0);
    set(handles.SelectionButton_Tracking_NN,'Value',1);  
guidata(hObject, handles);
function handles=UpdateITTransformOff(handles)
    set(handles.SelectionButton_Tracking_NN,'Enable','off');
    set(handles.SelectionButton_Tracking_NN_local,'Value',1);
    set(handles.SelectionButton_Tracking_NN,'Value',0); 
function handles=UpdateITTransformOn(handles)
    set(handles.SelectionButton_Tracking_NN,'Enable','on');
    set(handles.SelectionButton_Tracking_NN_local,'Value',0);
    set(handles.SelectionButton_Tracking_NN,'Value',1);  
% -- Check detection result --
function Button_CheckDetection_Callback(hObject, eventdata, handles)
set(handles.Button_CheckDetection,'Enable','off');
set(handles.Button_StartDHM,'Enable','off');
set(handles.PARA_Detection_CannyEdgeThreshHighMultiple,'Enable','off');

StartingFrame=handles.DataSource.FrameNumber-1;
handles.DataSource.GetFrame(StartingFrame);
% Preprocess
handles.DHMOperator.Preprocess(handles.DataSource.Im);
FirstFrameIm=handles.DHMOperator.Image;
% Hologram normalization
if(strcmp(handles.DHMOperator.PreProcessConfig.Backgroundsubtraction,'On') && strcmp(handles.DHMOperator.PreProcessConfig.Backgroundnorm,'Off')) 
     if(strcmp(handles.DHMOperator.PreProcessConfig.BackgroundsubtractionMethod,'Moving'))
        for i=1:handles.DHMOperator.PreProcessConfig.Backgroundframes
            handles.DHMOperator.BackgroundImage(:,:,i)=handles.DHMOperator.Image;
            handles.DataSource.GetFrame;
            handles.DHMOperator.Preprocess(handles.DataSource.Im);
        end
        handles.DHMOperator.IntensitySub(FirstFrameIm);
    else
        handles.DHMOperator.BackgroundSubStatic(handles.DHMOperator.Image);
    end
elseif(strcmp(handles.DHMOperator.PreProcessConfig.Backgroundsubtraction,'Off') && strcmp(handles.DHMOperator.PreProcessConfig.Backgroundnorm,'On'))
    if(strcmp(handles.DHMOperator.PreProcessConfig.BackgroundsubtractionMethod,'Moving'))
        for i=1:handles.DHMOperator.PreProcessConfig.Backgroundframes
            handles.DHMOperator.BackgroundImage(:,:,i)=handles.DHMOperator.Image;
            handles.DataSource.GetFrame;
            handles.DHMOperator.Preprocess(handles.DataSource.Im);
        end
        handles.DHMOperator.IntensityNorm(FirstFrameIm);
    else
        handles.DHMOperator.BackgroundHoloStatic(handles.DHMOperator.Image);
    end
end

% Manually Change threshold
CheckDetection(handles);

% Reset video
handles.DataSource.GetFrame(StartingFrame);
handles.DHMOperator.BacksubReady=0;
handles.DHMOperator.BacksubCounter=0;
handles.DHMOperator.BackgroundImage=[];
% Update GUI
set(handles.PARA_Detection_CannyEdgeThreshHighMultiple,'String',num2str(handles.DHMOperator.DetectionConfig.Method.EdgeThresh));
guidata(hObject, handles);
% -- Canny edge detection threshold value correction --
function PARA_Detection_CannyEdgeThreshHighMultiple_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Detection_CannyEdgeThreshHighMultiple (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.EdgeThresh));
    guidata(hObject, handles);
    return
end
[ITiteration, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.EdgeThresh));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
handles.DHMOperator.DetectionConfig.Method.EdgeThresh=ITiteration;

% Update GUI
set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.EdgeThresh));
guidata(hObject, handles);
function PARA_Detection_CannyEdgeThreshHighMultiple_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Detection_CannyEdgeThreshHighMultiple (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------------ITCiD parameters -------------------------
function PARA_Detection_ITCiD_ScaleNum_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Detection_ITCiD_ScaleNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.ITTrans.ScaleNum));
    guidata(hObject, handles);
    return
end
[ITScaleNum, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.ITTrans.ScaleNum));
    guidata(hObject, handles);
    return
end
handles.DHMOperator.DetectionConfig.Method.ITTrans.ScaleNum=ITScaleNum;

% Update GUI
set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.ITTrans.ScaleNum));
guidata(hObject, handles);
function PARA_Detection_ITCiD_ScaleNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Detection_ITCiD_ScaleNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_Detection_ITThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Detection_ITThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.ITTrans.ITThresh));
    guidata(hObject, handles);
    return
end
[ITsThreshold, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.ITTrans.ITThresh));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
handles.DHMOperator.DetectionConfig.Method.ITTrans.ITThresh=ITsThreshold;

% Update GUI
set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.ITTrans.ITThresh));
guidata(hObject, handles);
function PARA_Detection_ITThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Detection_ITThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_Detection_ITMinVotes_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Detection_ITMinVotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.ITTrans.MinVotes));
    guidata(hObject, handles);
    return
end
[ITminVote, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.ITTrans.MinVotes));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
handles.DHMOperator.DetectionConfig.Method.ITTrans.MinVotes=ITminVote;

% Update GUI
set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.ITTrans.MinVotes));
guidata(hObject, handles);
function PARA_Detection_ITMinVotes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Detection_ITMinVotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_Detection_Iterations_Callback(hObject, eventdata, handles)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.ITTrans.Iteration));
    guidata(hObject, handles);
    return
end
[ITiteration, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.ITTrans.Iteration));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
handles.DHMOperator.DetectionConfig.Method.ITTrans.Iteration=ITiteration;

% Update GUI
set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.ITTrans.Iteration));
guidata(hObject, handles);
function PARA_Detection_Iterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Detection_Iterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_Detection_ITCiD_LineLength_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Detection_ITCiD_LineLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.ITTrans.LineLength));
    guidata(hObject, handles);
    return
end
[Linelength, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.ITTrans.LineLength));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
handles.DHMOperator.DetectionConfig.Method.ITTrans.LineLength=Linelength;

% Update GUI
set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.ITTrans.LineLength));
guidata(hObject, handles);
function PARA_Detection_ITCiD_LineLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Detection_ITCiD_LineLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_Detection_ITCiD_MappingSize_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Detection_ITCiD_MappingSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.ITTrans.MappingRadius));
    guidata(hObject, handles);
    return
end
[ITiteration, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.ITTrans.MappingRadius));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
handles.DHMOperator.DetectionConfig.Method.ITTrans.MappingRadius=ITiteration;

% Update GUI
set(hObject,'String',num2str(handles.DHMOperator.DetectionConfig.Method.ITTrans.MappingRadius));
guidata(hObject, handles);
function PARA_Detection_ITCiD_MappingSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Detection_ITCiD_MappingSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -------------------------- Tracking parameters --------------------------
function PARA_Tracking_MaxDisplacement_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Tracking_MaxDisplacement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.TrackingConfig.NN.MaxDisplacement));
    guidata(hObject, handles);
    return
end
[MaxDisplacement, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.TrackingConfig.NN.MaxDisplacement));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
handles.DHMOperator.TrackingConfig.NN.MaxDisplacement=MaxDisplacement;

set(hObject,'String',num2str(handles.DHMOperator.TrackingConfig.NN.MaxDisplacement));
guidata(hObject, handles);
function PARA_Tracking_MaxDisplacement_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Tracking_MaxDisplacement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SelectionButton_Tracking_NN_Callback(hObject, ~, handles)
% hObject    handle to SelectionButton_Tracking_NN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggelValue=get(hObject,'Value');
if(toggelValue==1)
    % UpdateInstance
    handles.DHMOperator.TrackingConfig.NN.LocalDetection=0;

end
guidata(hObject, handles);
function SelectionButton_Tracking_NN_local_Callback(hObject, eventdata, handles)
% hObject    handle to SelectionButton_Tracking_NN_local (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of SelectionButton_Tracking_NN_local
toggelValue=get(hObject,'Value');
if(toggelValue==1)
    % UpdateInstance
    handles.DHMOperator.TrackingConfig.NN.LocalDetection=1;

end
guidata(hObject, handles);

function PARA_Tracking_FixedTemplateSize_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Tracking_FixedTemplateSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CheckValue=get(hObject,'Value');
if(CheckValue==1)
    % UpdateInstance
    handles.DHMOperator.TrackingConfig.FixedTemplate=1;
    
    set(handles.PARA_Tracking_TemplateSizeNum,'Enable','on');
else
    % UpdateInstance
    handles.DHMOperator.TrackingConfig.FixedTemplate=0;
    handles.DHMOperator.TrackingConfig.FixedTemplateSize=200;
    
    set(handles.PARA_Tracking_TemplateSizeNum,'Enable','off');
    set(handles.PARA_Tracking_TemplateSizeNum,'String',num2str(handles.DHMOperator.TrackingConfig.FixedTemplateSize));
end
guidata(hObject, handles);
function PARA_Tracking_TemplateSizeNum_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Tracking_TemplateSizeNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.TrackingConfig.FixedTemplateSize));
    guidata(hObject, handles);
    return
end
[ResizeNumber, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.TrackingConfig.FixedTemplateSize));
    guidata(hObject, handles);
    return
end
handles.DHMOperator.TrackingConfig.FixedTemplateSize=ResizeNumber;
set(hObject,'String',num2str(handles.DHMOperator.TrackingConfig.FixedTemplateSize));
guidata(hObject, handles);
function PARA_Tracking_TemplateSizeNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Tracking_TemplateSizeNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function PARA_Tracking_BoundaryROI_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Tracking_BoundaryROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CheckValue=get(hObject,'Value');
if(CheckValue==1)
    % UpdateInstance
    handles.DHMOperator.TrackingConfig.NN.TrackingROI='On';
else
    % UpdateInstance
    handles.DHMOperator.TrackingConfig.NN.TrackingROI='Off';
end
guidata(hObject, handles);
% -----------------------------Refine circle center------------------------
function PARA_Refinement_Xcorr_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Refinement_Xcorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CheckValue=get(hObject,'Value');
if(CheckValue==1)
    handles.DHMOperator.RefinementConfig.RefineCenter.Active.XCORR=1;
    set(handles.PARA_Refinement_XcorrMedianBackground,'Enable','on');
else
    handles.DHMOperator.RefinementConfig.RefineCenter.Active.XCORR=0;
    set(handles.PARA_Refinement_XcorrMedianBackground,'Enable','off');
end
% Update GUI
guidata(hObject, handles);
function PARA_Refinement_Resampling_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Refinement_Resampling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CheckValue=get(hObject,'Value');
if(CheckValue==1)
    handles.DHMOperator.RefinementConfig.Resample.Active=1;
    handles.DHMOperator.RefinementConfig.Resample.Pattern='Sector'; 
    set(handles.PARA_Resample_Sector,'Enable','on');
    set(handles.PARA_Resample_Circular,'Enable','on');
else
    handles.DHMOperator.RefinementConfig.Resample.Active=0;
    handles.DHMOperator.RefinementConfig.Resample.Pattern='None'; 
    set(handles.PARA_Resample_Sector,'Enable','off');
    set(handles.PARA_Resample_Circular,'Enable','off');
end
% Update GUI
guidata(hObject, handles);
function PARA_Refinement_XcorrMedianBackground_Callback(hObject, ~, handles)
% hObject    handle to PARA_Refinement_XcorrMedianBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CheckValue=get(hObject,'Value');
if(CheckValue==1)
    handles.DHMOperator.RefinementConfig.RefineCenter.XCorr.MedianFilter=1;
else
    handles.DHMOperator.RefinementConfig.RefineCenter.XCorr.MedianFilter=0;
end
% Update GUI
guidata(hObject, handles);
% ---------------------Circular object profile Sampling--------------------
function PARA_Resample_Circular_Callback(hObject, eventdata, handles)
toggelValue=get(hObject,'Value');
if(toggelValue==1)
    % UpdateInstance
    handles.DHMOperator.RefinementConfig.Resample.Pattern='Circular';
end
guidata(hObject, handles);
function PARA_Resample_Sector_Callback(hObject, eventdata, handles)
toggelValue=get(hObject,'Value');
if(toggelValue==1)
    % UpdateInstance
    handles.DHMOperator.RefinementConfig.Resample.Pattern='Sector';
end
guidata(hObject, handles);
% --------------------------SelectReconstructionMethod---------------------
function SelectionButton_Reconstruction_1D_Callback(hObject, ~, handles)
toggelValue=get(hObject,'Value');
if(toggelValue==1)
    % UpdateInstance
    handles.DHMOperator.ReconstructConfig.Method='1D';
end
function SelectionButton_Reconstruction_1DDecov_Callback(hObject, ~, handles)
toggelValue=get(hObject,'Value');
if(toggelValue==1)
    % UpdateInstance
    handles.DHMOperator.ReconstructConfig.Method='1DDecov';
end
function SelectionButton_Reconstruction_2D_Callback(hObject, ~, handles)
toggelValue=get(hObject,'Value');
if(toggelValue==1)
    % UpdateInstance
    handles.DHMOperator.ReconstructConfig.Method='2D';
end
% --------------------------------DHM parameters --------------------------
function PARA_Reconstruction_TemplateMargin_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Reconstruction_TemplateMargin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.TemplateResize));
    guidata(hObject, handles);
    return
end
[TemplateResize, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.TemplateResize));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
handles.DHMOperator.ReconstructConfig.Basic.TemplateResize=TemplateResize;

set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.TemplateResize));
guidata(hObject, handles);
function PARA_Reconstruction_TemplateMargin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Reconstruction_TemplateMargin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_Reconstruciton_TemplateSize_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Reconstruciton_TemplateSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.ImageResize));
    guidata(hObject, handles);
    return
end
[ImageResize, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.ImageResize));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
handles.DHMOperator.ReconstructConfig.Basic.ImageResize=ImageResize;

handles.DHMOperator.ReconstructConfig.Basic.StopStep=handles.DHMOperator.ReconstructConfig.Basic.StopStep/ImageResize;
handles.DHMOperator.ReconstructConfig.Basic.StartStep=handles.DHMOperator.ReconstructConfig.Basic.StartStep/ImageResize;
handles.DHMOperator.ReconstructConfig.Basic.StepSize=handles.DHMOperator.ReconstructConfig.Basic.StepSize/ImageResize;

% Update Interface (Tracking properties)
set(handles.PARA_Reconstruction_EndStep,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StopStep));
set(handles.PARA_Reconstruction_InitStep,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StartStep));
set(handles.PARA_Reconstruction_StepSize,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StepSize));
set(handles.PARA_Reconstruction_StepResolution,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StepSize*handles.DHMOperator.ReconstructConfig.Basic.Lambda*1e6,'%10.2f'));
set(handles.PARA_Reconstruction_NumofSteps,'String',num2str((handles.DHMOperator.ReconstructConfig.Basic.StopStep-handles.DHMOperator.ReconstructConfig.Basic.StartStep+1)/handles.DHMOperator.ReconstructConfig.Basic.StepSize,'%10.0f'));
set(handles.PARA_Reconstruction_PixelSpacing,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.PixelSpacing*1e9));

%
handles.DHMOperator.ReconstructConfig.ConvertZ=handles.DHMOperator.ReconstructConfig.Basic.ImageResize*...
    handles.DHMOperator.ReconstructConfig.Basic.StepSize*...
    handles.DHMOperator.ReconstructConfig.Basic.Lambda*...
    handles.DHMOperator.PreProcessConfig.Resize.Num;

set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.ImageResize));
guidata(hObject, handles);
function PARA_Reconstruciton_TemplateSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Reconstruciton_TemplateSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_Reconstruction_StepSize_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Reconstruction_StepSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StepSize));
    guidata(hObject, handles);
    return
end
[StepSize, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StepSize));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
handles.DHMOperator.ReconstructConfig.Basic.StepSize=max(0.001,StepSize);
handles.DHMOperator.ReconstructConfig.ConvertZ=1/(handles.DHMOperator.ReconstructConfig.Basic.ImageResize)*...
    handles.DHMOperator.ReconstructConfig.Basic.StepSize*...
    handles.DHMOperator.ReconstructConfig.Basic.Lambda*...
    handles.DHMOperator.PreProcessConfig.Resize.Num;

set(handles.PARA_Reconstruction_StepResolution,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StepSize*handles.DHMOperator.ReconstructConfig.Basic.Lambda*1e6,'%10.2f'));
set(handles.PARA_Reconstruction_NumofSteps,'String',num2str((handles.DHMOperator.ReconstructConfig.Basic.StopStep-handles.DHMOperator.ReconstructConfig.Basic.StartStep+1)/handles.DHMOperator.ReconstructConfig.Basic.StepSize,'%10.0f'));
set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StepSize));
guidata(hObject, handles);
function PARA_Reconstruction_StepSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Reconstruction_StepSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_Reconstruction_InitStep_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Reconstruction_InitStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StartStep));
    guidata(hObject, handles);
    return
end
[StartDistance, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StartStep));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
StartStep=round(StartDistance/(handles.DHMOperator.ReconstructConfig.Basic.Lambda*1e6));
handles.DHMOperator.ReconstructConfig.Basic.StartStep=max(1,StartStep);
set(handles.PARA_Reconstruction_StepResolution,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StepSize*handles.DHMOperator.ReconstructConfig.Basic.Lambda*1e6,'%10.2f'));
set(handles.PARA_Reconstruction_NumofSteps,'String',num2str((handles.DHMOperator.ReconstructConfig.Basic.StopStep-handles.DHMOperator.ReconstructConfig.Basic.StartStep+1)/handles.DHMOperator.ReconstructConfig.Basic.StepSize,'%10.0f'));
set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StartStep*handles.DHMOperator.ReconstructConfig.Basic.Lambda*1e6,'%10.2f'));
guidata(hObject, handles);
function PARA_Reconstruction_InitStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Reconstruction_InitStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_Reconstruction_EndStep_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Reconstruction_EndStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StopStep));
    guidata(hObject, handles);
    return
end
[StopDistance, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StopStep));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
StopStep=round(StopDistance/(handles.DHMOperator.ReconstructConfig.Basic.Lambda*1e6));
if(StopStep>handles.DHMOperator.ReconstructConfig.Basic.StartStep)
    handles.DHMOperator.ReconstructConfig.Basic.StopStep=StopStep;
else
    handles.DHMOperator.ReconstructConfig.Basic.StopStep=handles.DHMOperator.ReconstructConfig.Basic.StartStep+400;
end
set(handles.PARA_Reconstruction_StepResolution,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StepSize*handles.DHMOperator.ReconstructConfig.Basic.Lambda*1e6,'%10.2f'));
set(handles.PARA_Reconstruction_NumofSteps,'String',num2str((handles.DHMOperator.ReconstructConfig.Basic.StopStep-handles.DHMOperator.ReconstructConfig.Basic.StartStep+1)/handles.DHMOperator.ReconstructConfig.Basic.StepSize,'%10.0f'));
set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StopStep*handles.DHMOperator.ReconstructConfig.Basic.Lambda*1e6,'%10.2f'));
guidata(hObject, handles);
function PARA_Reconstruction_EndStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Reconstruction_EndStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_Reconstruction_Wavelength_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Reconstruction_Wavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.Wavelength*1e9));
    guidata(hObject, handles);
    return
end
[Wavelength, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.Wavelength*1e9));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
Wavelength=Wavelength*1e-9;
handles.DHMOperator.ReconstructConfig.Basic.Wavelength=Wavelength;
handles.DHMOperator.ReconstructConfig.Basic.Lambda=Wavelength/handles.DHMOperator.ReconstructConfig.Basic.RefractiveIndex;
handles.DHMOperator.ReconstructConfig.ConvertZ=1/(handles.DHMOperator.ReconstructConfig.Basic.ImageResize)*...
    handles.DHMOperator.ReconstructConfig.Basic.StepSize*...
    handles.DHMOperator.ReconstructConfig.Basic.Lambda;

set(handles.PARA_Reconstruction_StepResolution,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StepSize*handles.DHMOperator.ReconstructConfig.Basic.Lambda*1e6,'%10.2f'));
set(handles.PARA_Reconstruction_NumofSteps,'String',num2str((handles.DHMOperator.ReconstructConfig.Basic.StopStep-handles.DHMOperator.ReconstructConfig.Basic.StartStep+1)/handles.DHMOperator.ReconstructConfig.Basic.StepSize,'%10.0f'));
set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.Wavelength*1e9));
guidata(hObject, handles);
function PARA_Reconstruction_Wavelength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Reconstruction_Wavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_Reconstruction_RefractiveIndex_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Reconstruction_RefractiveIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.RefractiveIndex));
    guidata(hObject, handles);
    return
end
[RefractiveIndex, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.RefractiveIndex));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
handles.DHMOperator.ReconstructConfig.Basic.RefractiveIndex=RefractiveIndex;
handles.DHMOperator.ReconstructConfig.Basic.Lambda=handles.DHMOperator.ReconstructConfig.Basic.Wavelength/RefractiveIndex;
handles.DHMOperator.ReconstructConfig.ConvertZ=1/(handles.DHMOperator.ReconstructConfig.Basic.ImageResize)*...
    handles.DHMOperator.ReconstructConfig.Basic.StepSize*...
    handles.DHMOperator.ReconstructConfig.Basic.Lambda;

set(handles.PARA_Reconstruction_StepResolution,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.StepSize*handles.DHMOperator.ReconstructConfig.Basic.Lambda*1e6,'%10.2f'));
set(handles.PARA_Reconstruction_NumofSteps,'String',num2str((handles.DHMOperator.ReconstructConfig.Basic.StopStep-handles.DHMOperator.ReconstructConfig.Basic.StartStep+1)/handles.DHMOperator.ReconstructConfig.Basic.StepSize,'%10.0f'));
set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.RefractiveIndex));
guidata(hObject, handles);
function PARA_Reconstruction_RefractiveIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Reconstruction_RefractiveIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_Reconstruction_PixelSpacing_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Reconstruction_PixelSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.PixelSpacing*1e9));
    guidata(hObject, handles);
    return
end
[PixelSpacing, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.PixelSpacing*1e9));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
PixelSpacing=PixelSpacing*1e-9;
handles.DHMOperator.ReconstructConfig.Basic.PixelSpacing=PixelSpacing;

set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.PixelSpacing*1e9));
guidata(hObject, handles);
function PARA_Reconstruction_PixelSpacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Reconstruction_PixelSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_Reconstruction_ParaMask_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Reconstruction_ParaMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.ParaxialMask));
    guidata(hObject, handles);
    return
end
[ParaxialMask, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.ParaxialMask));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
handles.DHMOperator.ReconstructConfig.Basic.ParaxialMask=ParaxialMask;

set(hObject,'String',num2str(handles.DHMOperator.ReconstructConfig.Basic.ParaxialMask));
guidata(hObject, handles);
function PARA_Reconstruction_ParaMask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Reconstruction_ParaMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_Reconstruction_Enable_Callback(hObject, ~, handles)
% hObject    handle to PARA_Reconstruction_Enable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CheckValue=get(hObject,'Value');
if(CheckValue==0)
    set(handles.PARA_Reconstruction_Enable,'Value',0);
    set(handles.SelectionButton_Reconstruction_1D,'Enable','off');
    set(handles.SelectionButton_Reconstruction_1DDecov,'Enable','off');
    set(handles.SelectionButton_Reconstruction_2D,'Enable','off');
    set(handles.PARA_Reconstruction_TemplateMargin,'Enable','off');
    set(handles.PARA_Reconstruciton_TemplateSize,'Enable','off');
    set(handles.PARA_Reconstruction_ParaMask,'Enable','off');
    set(handles.PARA_Reconstruction_StepSize,'Enable','off');
    set(handles.PARA_Reconstruction_InitStep,'Enable','off');
    set(handles.PARA_Reconstruction_EndStep,'Enable','off');
    handles.DHMOperator.ReconstructConfig.Active=0;
else
    set(handles.PARA_Reconstruction_Enable,'Value',1);
    set(handles.SelectionButton_Reconstruction_1D,'Enable','on');
    set(handles.SelectionButton_Reconstruction_1DDecov,'Enable','off');
    set(handles.SelectionButton_Reconstruction_2D,'Enable','on');
    set(handles.PARA_Reconstruction_TemplateMargin,'Enable','on');
    set(handles.PARA_Reconstruciton_TemplateSize,'Enable','on');
    if(strcmp(handles.DHMOperator.ReconstructConfig.Method,'1D'))
        set(handles.PARA_Reconstruction_ParaMask,'Enable','on');
    elseif(strcmp(handles.DHMOperator.ReconstructConfig.Method,'1DDecov'))
        set(handles.PARA_Reconstruction_ParaMask,'Enable','off');
    else
        set(handles.PARA_Reconstruction_ParaMask,'Enable','off');
    end
    set(handles.PARA_Reconstruction_StepSize,'Enable','on');
    set(handles.PARA_Reconstruction_InitStep,'Enable','on');
    set(handles.PARA_Reconstruction_EndStep,'Enable','on');
    set(handles.PARA_Reconstruction_Wavelength,'Enable','on');
    set(handles.PARA_Reconstruction_RefractiveIndex,'Enable','on');
    set(handles.PARA_Reconstruction_PixelSpacing,'Enable','on');
    handles.DHMOperator.ReconstructConfig.Active=1;
end
% Update GUI
guidata(hObject, handles);
% --------------------------------Save Image ------------------------------
function PARA_DATA_SaveTrackingImages_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_DATA_SaveTrackingImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CheckValue=get(hObject,'Value');
if(CheckValue==1)
    handles.DataCollector.DataConfig.WriteFrame=1;
else
    handles.DataCollector.DataConfig.WriteFrame=0;
end
% Update GUI
guidata(hObject, handles);

% -----------------------------Present Image ------------------------------
function PARA_DATA_PresentTrackingImages_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_DATA_PresentTrackingImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CheckValue=get(hObject,'Value');
if(CheckValue==1)
    handles.DataCollector.DataConfig.PresentTrack=1;
else
    handles.DataCollector.DataConfig.PresentTrack=0;
    if(~isempty(handles.DataCollector.DataConfig.Fig1))
        if(isvalid(handles.DataCollector.DataConfig.Fig1))
           close(handles.DataCollector.DataConfig.Fig1);
        end
    end
end

% Update GUI
guidata(hObject, handles);
function PARA_DATA_PresentReconstruction_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_DATA_PresentReconstruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CheckValue=get(hObject,'Value');
if(CheckValue==1)
    handles.DataCollector.DataConfig.PresentReconstruction=1;
else
    handles.DataCollector.DataConfig.PresentReconstruction=0;
    if(~isempty(handles.DataCollector.DataConfig.Fig2))
        if(isvalid(handles.DataCollector.DataConfig.Fig2))
            close(handles.DataCollector.DataConfig.Fig2);
        end
    end
end
% Update GUI
guidata(hObject, handles);
% ------------------------------Present Frame------------------------------
function updateImageFirstFrame(handles)
% Preprocess
handles.DHMOperator.Preprocess(handles.DataSource.Im);
FirstFrameIm=handles.DHMOperator.Image;
% Hologram normalization
if(strcmp(handles.DHMOperator.PreProcessConfig.Backgroundsubtraction,'On') && strcmp(handles.DHMOperator.PreProcessConfig.Backgroundnorm,'Off')) 
     if(strcmp(handles.DHMOperator.PreProcessConfig.BackgroundsubtractionMethod,'Moving'))
        StartingFrame=handles.DataSource.FrameNumber-1;
        handles.DHMOperator.Preprocess(handles.DataSource.Im);
        for i=1:handles.DHMOperator.PreProcessConfig.Backgroundframes
            handles.DHMOperator.BackgroundImage(:,:,i)=handles.DHMOperator.Image;
            handles.DataSource.GetFrame;
            handles.DHMOperator.Preprocess(handles.DataSource.Im);
        end
        handles.DataSource.GetFrame(StartingFrame);
        handles.DHMOperator.Preprocess(handles.DataSource.Im);
        handles.DHMOperator.IntensitySub(FirstFrameIm);
    else
        handles.DHMOperator.BackgroundSubStatic(handles.DHMOperator.Image);
    end
elseif(strcmp(handles.DHMOperator.PreProcessConfig.Backgroundsubtraction,'Off') && strcmp(handles.DHMOperator.PreProcessConfig.Backgroundnorm,'On'))
    if(strcmp(handles.DHMOperator.PreProcessConfig.BackgroundsubtractionMethod,'Moving'))
        StartingFrame=handles.DataSource.FrameNumber-1;
        handles.DHMOperator.Preprocess(handles.DataSource.Im);
        for i=1:handles.DHMOperator.PreProcessConfig.Backgroundframes
            handles.DHMOperator.BackgroundImage(:,:,i)=handles.DHMOperator.Image;
            handles.DataSource.GetFrame;
            handles.DHMOperator.Preprocess(handles.DataSource.Im);
        end
        handles.DataSource.GetFrame(StartingFrame);
        handles.DHMOperator.Preprocess(handles.DataSource.Im);
        handles.DHMOperator.IntensityNorm(FirstFrameIm);
    else
        handles.DHMOperator.BackgroundHoloStatic(handles.DHMOperator.Image);
    end
end
% Reset video
handles.DHMOperator.BacksubReady=0;
handles.DHMOperator.BacksubCounter=0;
handles.DHMOperator.BackgroundImage=[];
imshow(handles.DHMOperator.Image,'Parent',handles.Axes_VideoFrame);

function slider_FirstFrame_Callback(hObject, eventdata, handles)
set(hObject,'Enable','off');
CurrentFrameNumberNorm=get(hObject,'value');
CurrentFrameNumber=round(CurrentFrameNumberNorm*(handles.DataSource.TotalFrames-1));
if(CurrentFrameNumber>=0 && CurrentFrameNumber<=(handles.DataSource.TotalFrames-1))
    handles.DataSource.GetFrame(CurrentFrameNumber);
    Update_EditFirstFrameNum(handles,handles.DataSource.FrameNumber)
    updateImageFirstFrame(handles);
end
set(hObject,'Enable','on');
guidata(hObject, handles);
function slider_FirstFrame_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function Update_slider_FirstFrame(handles,value)
set(handles.slider_FirstFrame,'value',value);

function Edit_FirstFrameNum_Callback(hObject, eventdata, handles)
set(hObject,'Enable','off');
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.DataSource.FrameNumber));
    guidata(hObject, handles);
    return
end
[CurrentFrameNumber, status] = str2num(Numstring);
CurrentFrameNumber_Check=CurrentFrameNumber-1;
if(status==0)
    set(hObject,'String',num2str(handles.DataSource.FrameNumber));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
if(CurrentFrameNumber_Check>=0 && CurrentFrameNumber_Check<=(handles.DataSource.TotalFrames-1))
    handles.DataSource.GetFrame(CurrentFrameNumber_Check);
    handles.DataSource.FrameNumber=CurrentFrameNumber_Check;
    set(hObject,'String',num2str(CurrentFrameNumber));
    handles.DataSource.GetFrame(CurrentFrameNumber_Check);
    updateImageFirstFrame(handles);
    Update_slider_FirstFrame(handles,CurrentFrameNumber/handles.DataSource.TotalFrames);
end
set(hObject,'Enable','on');
guidata(hObject, handles);
function Edit_FirstFrameNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_FirstFrameNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Update_EditFirstFrameNum(handles,CurrentFrameNumber)
set(handles.Edit_FirstFrameNum,'String',num2str(CurrentFrameNumber));

function listbox_VideoInfo_Callback(hObject, eventdata, handles)
function listbox_VideoInfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_VideoInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Update_listbox_VideoInfo(handles)
Present_video{1}='Total frames: ';
Present_video{2}=num2str(handles.DataSource.TotalFrames,'%10.0d');
Present_video{3}='Frame rate: ';
%Present_video{4}=num2str(handles.DataSource.FrameRate,'%10.2f');
Present_video{4}= '9.69';
Present_video{5}='Duration: ';
%Present_video{6}=num2str(handles.DataSource.VideoSrc.Duration,'%10.2f');
Present_video{6}='120';
Present_video{7}='Time interval: ';
%Present_video{8}=num2str(handles.DataSource.VideoSrc.CurrentTime,'%10.2f');
Present_video{8} = '--';
Present_video{9}='Bits per pixel: ';
Present_video{10}=num2str(handles.DataSource.VideoSrc.BitsPerPixel,'%10.0d');
Present_video{11}='Video format: ';
Present_video{12}=handles.DataSource.VideoSrc.VideoFormat;
Present_video{13}='Frame dimension: ';
Present_video{14}=num2str(ndims(handles.DataSource.Im),'%10.0d');
set(handles.listbox_VideoInfo,'String',Present_video);
% -------------------------------FileOut-----------------------------------
function OutputFolderPath_Callback(hObject, eventdata, handles)
% hObject    handle to OutputFolderPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FolderName=get(hObject,'String');
if(~isempty(FolderName))
    % UpdateInstance
    handles.DataCollector.DataConfig.PathResults=strcat(FolderName,'\');
    handles.DataCollector.Update;
end
set(hObject,'String',handles.DataCollector.DataConfig.PathResults(1:end-1));
guidata(hObject, handles);
function OutputFolderPath_CreateFcn(hObject, ~, handles)
% hObject    handle to OutputFolderPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --------------------------------Save config -----------------------------
function BUTTON_SAVE_CONFIG_Callback(hObject, ~, handles)
userData = get(handles.output, 'UserData');

SaveData.GPUConfig=handles.DHMOperator.GPUConfig;
SaveData.CPUConfig=handles.DHMOperator.CPUConfig;
SaveData.PreProcessConfig=handles.DHMOperator.PreProcessConfig;
SaveData.DetectionConfig=handles.DHMOperator.DetectionConfig;
SaveData.TrackingConfig=handles.DHMOperator.TrackingConfig;
SaveData.RefinementConfig=handles.DHMOperator.RefinementConfig;
SaveData.ReconstructConfig=handles.DHMOperator.ReconstructConfig;
SaveData.OutputConfig= handles.DataCollector.DataConfig;
% Update Interface
set(handles.BUTTON_LOAD_CONFIG,'Enable','off');
% Save configurations
save(userData.SaveConfigName,'SaveData');
% Update Interface
set(handles.BUTTON_LOAD_CONFIG,'Enable','on');
guidata(hObject, handles);
function BUTTON_LOAD_CONFIG_Callback(hObject, ~, handles)
[filename, pathname] = uigetfile( ...
    {'*.mat;','Configuration Files (*.mat)';
    '*.*',  'All Files (*.*)'}, ...
    'Select a configuration file');
if(sum(pathname==0) || sum(filename==0))
    disp('Cancelled...');
    return
else
    GetData=load(strcat(pathname,filename));
    % Update Parameters
    handles.Config=GetData.SaveData;
    handles=InitializeParameters(handles);
end
guidata(hObject, handles);
function TEXT_PARA_SAVE_CONFIG_Callback(hObject, ~, handles)
% hObject    handle to TEXT_PARA_SAVE_CONFIG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userData = get(handles.output, 'UserData');
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(userData.SaveConfigName));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
userData.SaveConfigName=Numstring;
set(handles.output,'UserData',userData);

% Update GUI
set(handles.TEXT_PARA_SAVE_CONFIG,'String',userData.SaveConfigName);
guidata(hObject, handles);
function TEXT_PARA_SAVE_CONFIG_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------Postprocessing---------------------------
function PARA_POSTPROCESS_MAIN_Callback(hObject, eventdata, handles)
function PARA_POSTPROCESS_FlowProfiling_MAIN_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_POSTPROCESS_FlowProfiling_MAIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CheckFlowProfile();
function PARA_POSTPROCESS_SingleTrack_MAIN_Callback(hObject, eventdata, handles)
CheckSingleTrack();
% ------------------------------Exit program-------------------------------
function Menu_Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% Computing Cores
if isempty(gcp('nocreate'))==0 % checking to see if my pool is already open
    poolobj = gcp('nocreate');
    delete(poolobj);
end
close(handles.figure_UmUTracker);

% ------------------------------Parallel compt-----------------------------
function PARA_ActivateCPUComputing_Callback(hObject, eventdata, handles)
CheckValue=get(hObject,'Value');
if(CheckValue==1)
    % UpdateInstance
    handles.DHMOperator.CPUConfig.ParForActive=1;
else
    % UpdateInstance
    handles.DHMOperator.CPUConfig.ParForActive=0;
end
guidata(hObject, handles);
function CHECK_AccGPU_Callback(hObject, eventdata, handles)
CheckValue=get(hObject,'Value');
try
        gpuArray(1);
        disp('GPU based functions are available.');
        GPU_Active=1;
catch        
        disp('GPU based functions are not available for this pc.');
        GPU_Active=0;
end

if(GPU_Active*CheckValue==1)
    handles.DHMOperator.GPUConfig.Active=1;
else
    handles.DHMOperator.GPUConfig.Active=0;
    disp('GPU based functions are de-activated.');
end
guidata(hObject, handles);

function PARA_BlobDetection_MinSize_Callback(hObject, eventdata, handles)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.Config.DetectionConfig.Method.MinSize));
    guidata(hObject, handles);
    return
end
[temp, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.Config.DetectionConfig.Method.MinSize));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
if(temp<handles.Config.DetectionConfig.Method.MaxSize && temp>=0)
    handles.Config.DetectionConfig.Method.MinSize=temp;
end
% Update GUI
set(hObject,'String',num2str(handles.Config.DetectionConfig.Method.MinSize));
guidata(hObject, handles);
function PARA_BlobDetection_MinSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_BlobDetection_MaxSize_Callback(hObject, eventdata, handles)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.Config.DetectionConfig.Method.MaxSize));
    guidata(hObject, handles);
    return
end
[temp, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.Config.DetectionConfig.Method.MaxSize));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
if(temp>handles.Config.DetectionConfig.Method.MinSize && temp>=0)
    handles.Config.DetectionConfig.Method.MaxSize=temp;
end
% Update GUI
set(hObject,'String',num2str(handles.Config.DetectionConfig.Method.MaxSize));
guidata(hObject, handles);
function PARA_BlobDetection_MaxSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_BlobDetection_MorphKernelSize_Callback(hObject, eventdata, handles)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.Config.DetectionConfig.Method.MorphKernelSize));
    guidata(hObject, handles);
    return
end
[temp, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.Config.DetectionConfig.Method.MorphKernelSize));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
if(temp>=1)
    handles.Config.DetectionConfig.Method.MorphKernelSize=temp;
end
% Update GUI
set(hObject,'String',num2str(handles.Config.DetectionConfig.Method.MorphKernelSize));
guidata(hObject, handles);
function PARA_BlobDetection_MorphKernelSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PARA_BlobDetection_IntensityMaskThresholdValue_Callback(hObject, eventdata, handles)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.Config.DetectionConfig.Method.BinaryMaskLevel));
    guidata(hObject, handles);
    return
end
[temp, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.Config.DetectionConfig.Method.BinaryMaskLevel));
    guidata(hObject, handles);
    return
end
% Update Parameters (Configuration & instance)
if(temp>=0 && temp<=1)
    handles.Config.DetectionConfig.Method.BinaryMaskLevel=temp;
end
% Update GUI
set(hObject,'String',num2str(handles.Config.DetectionConfig.Method.BinaryMaskLevel));
guidata(hObject, handles);
function PARA_BlobDetection_IntensityMaskThresholdValue_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
