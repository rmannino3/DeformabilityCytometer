function varargout = CheckFlowProfile(varargin)
% CHECKFLOWPROFILE MATLAB code for CheckFlowProfile.fig
%      CHECKFLOWPROFILE, by itself, creates a new CHECKFLOWPROFILE or raises the existing
%      singleton*.
%
%      H = CHECKFLOWPROFILE returns the handle to a new CHECKFLOWPROFILE or the handle to
%      the existing singleton*.
%
%      CHECKFLOWPROFILE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHECKFLOWPROFILE.M with the given input arguments.
%
%      CHECKFLOWPROFILE('Property','Value',...) creates a new CHECKFLOWPROFILE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CheckFlowProfile_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CheckFlowProfile_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CheckFlowProfile

% Last Modified by GUIDE v2.5 30-May-2017 11:14:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CheckFlowProfile_OpeningFcn, ...
                   'gui_OutputFcn',  @CheckFlowProfile_OutputFcn, ...
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


% --- Executes just before CheckFlowProfile is made visible.
function CheckFlowProfile_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CheckFlowProfile (see VARARGIN)

% Choose default command line output for CheckFlowProfile
handles.output = hObject;

%% Parameters settings
handles.Para.FrameRate=300;
handles.Para.MinTrackSize=10;
handles.Para.MaximumHeight=100;
handles.Para.MinimumHeight=5;
handles.Para.MinTravelDistance=10;
handles.Para.StdevX=500;
handles.Para.StdevY=5;
handles.Para.StdevZ=2;

handles.Para.XYViewZslicePosition=0;
handles.Para.XZViewYslicePosition=0;
handles.Para.YZViewXslicePosition=0;

handles.binSize=20;

handles.Para.FittingOrder=2;
handles.Para.FittingMinimumHeight=handles.Para.MinimumHeight;
handles.Para.FittingMaximumHeight=handles.Para.MaximumHeight;

handles.Para.ProfileAxis=3;
handles.Para.SamplePoints=5;
handles.Para.BinNumber=20;

set(handles.PARA_FrameRate,'String',num2str(handles.Para.FrameRate));
set(handles.PARA_MinHeight,'String',num2str(handles.Para.MinimumHeight));
set(handles.PARA_MaxHeight,'String',num2str(handles.Para.MaximumHeight));
set(handles.PARA_MinTrackSize,'String',num2str(handles.Para.MinTrackSize));
set(handles.PARA_MinTravelDistance,'String',num2str(handles.Para.MinTravelDistance));
set(handles.PARA_TravelStandardDevX,'String',num2str(handles.Para.StdevX));
set(handles.PARA_TravelStandardDevY,'String',num2str(handles.Para.StdevY));
set(handles.PARA_TravelStandardDevZ,'String',num2str(handles.Para.StdevZ));
set(handles.XZViewYslicePosition,'String',num2str(handles.Para.XZViewYslicePosition));
set(handles.YZViewXslicePosition,'String',num2str(handles.Para.YZViewXslicePosition));
set(handles.XYViewZslicePosition,'String',num2str(handles.Para.XYViewZslicePosition));

set(handles.PARA_Fitting_minDist,'String',num2str(handles.Para.FittingMinimumHeight));
set(handles.PARA_Fitting_maxDist,'String',num2str(handles.Para.FittingMaximumHeight));
set(handles.PARA_FittingOrder,'String',num2str(handles.Para.FittingOrder));
set(handles.PARA_FittingBins,'String',num2str(handles.Para.BinNumber));

handles=DisableButtomsEXE(handles);
%% Initilize Data
handles.FlowVelocityProfile_mean=[];
handles.FlowVelocityProfile_standdev=[];
% Update handles structure
guidata(hObject, handles);
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
Functions_FilesSaveName='LocalSaves';
Functions_FolderSaveName=strcat(ProgramFolder,'\',Functions_FilesSaveName);
if ~exist(Functions_FolderSaveName,'dir')
     mkdir(Functions_FolderSaveName);
end   
handles.Para.Functions_FolderSaveName=Functions_FolderSaveName;

handles.PostP_Inst=CLASS_PostProcessing;
handles.PostP_Inst.Load;
if(handles.PostP_Inst.PostP_DataSize~=0)
    set(handles.Button_Analyze,'Enable','on');
end
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = CheckFlowProfile_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.output = hObject;
% 
% % Get default command line output from handles structure
% varargout{1} = handles.output;


% --- Executes on button press in Button_Analyze.
function Button_Analyze_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Height
handles=DisableButtomsEXE(handles);
guidata(hObject, handles);
pause(0.1); 

[handles,ValidTrackNum]=PlotScatterData(handles);

figure(handles.figure_flowprofile)
axes(handles.AXES_4DProfile);
xlabel('x (um)');
ylabel('y (um)');
zlabel('z (um)');
zlim([handles.Para.MinimumHeight handles.Para.MaximumHeight])
colormap(jet);
hcolor =colorbar;
hcolor.Label.String = 'Speed (um/s)';
hold off;

if(isempty(handles.Data.FlowVelocityProfile_mean))
    handles=EnableButtomsEXE(handles);
    return
end 
FlowHeight_vs_VelocityProfile_mean=handles.Data.FlowVelocityProfile_mean(:,3:4);
[~,I] = sort(FlowHeight_vs_VelocityProfile_mean(:,1));
ProfileData=zeros(size(FlowHeight_vs_VelocityProfile_mean));
ProfileVelocityERROR=zeros(size(handles.Data.FlowVelocityProfile_error));
for i_sort=1:ValidTrackNum-1
     ProfileData(i_sort,:)=FlowHeight_vs_VelocityProfile_mean(I(i_sort),:);
     ProfileVelocityERROR(i_sort)=handles.Data.FlowVelocityProfile_error(I(i_sort));
end

bin=handles.Para.BinNumber;
interval=round(max(ProfileData(:,1))/bin);
LowL=min(handles.Para.MinimumHeight,handles.Para.FittingMinimumHeight);
HighL=max(handles.Para.MaximumHeight,handles.Para.FittingMaximumHeight);


for i_sort=1:ValidTrackNum-1
   if ProfileData(i_sort,1)>=handles.Para.FittingMinimumHeight
       SampleFitLow=i_sort;
       break;
   end
end

for i_sort=ValidTrackNum-1:-1:1
   if ProfileData(i_sort,1)<=handles.Para.FittingMaximumHeight
       SampleFitHigh=i_sort;
       break;
   end
end

Fitting_X = LowL:interval:HighL;

inc=1;
i_add=1;
SampleN=zeros(size(Fitting_X));
Profile_Std_SampleError=zeros(size(Fitting_X));
for i_error=LowL:interval:HighL
    HeightLevel=i_error;
    while(ProfileData(inc,1)<HeightLevel+0.5)
        Profile_Std_SampleError(i_add)=ProfileVelocityERROR(inc)+Profile_Std_SampleError(i_add);
        SampleN(i_add)=SampleN(i_add)+1;
        if(inc>=ValidTrackNum-1)
            break;
        end
        inc=inc+1;
    end
    i_add=i_add+1;
end
Profile_Std_SampleError=Profile_Std_SampleError./(1+SampleN);

figure(handles.figure_flowprofile)
axes(handles.AXES_Profile_Fitting);
plot(ProfileData(:,1),ProfileData(:,2),'.k','MarkerSize',10);hold on;
plot(ProfileData(SampleFitLow:SampleFitHigh,1),ProfileData(SampleFitLow:SampleFitHigh,2),'.b','MarkerSize',10);
PARA_Fit = polyfit(ProfileData(SampleFitLow:SampleFitHigh,1),ProfileData(SampleFitLow:SampleFitHigh,2),handles.Para.FittingOrder);
Yresidual= ProfileData(SampleFitLow:SampleFitHigh,2)-polyval(PARA_Fit,ProfileData(SampleFitLow:SampleFitHigh,1));
Sresidual=sum(Yresidual.^2);
SStotal = (length(ProfileData(SampleFitLow:SampleFitHigh,2))-1) * var(ProfileData(SampleFitLow:SampleFitHigh,2));
RSQ = 1 - Sresidual/SStotal;
Fitting_Y = polyval(PARA_Fit,Fitting_X);
errorbar(Fitting_X,Fitting_Y,Profile_Std_SampleError,'-k','MarkerSize',10,'LineWidth',1);hold on;
[pks,locs] =findpeaks(Fitting_Y,Fitting_X);
plot(locs,pks,'or','MarkerSize',10);hold on;
xlim([min(handles.Para.MinimumHeight,handles.Para.FittingMinimumHeight), max(handles.Para.MaximumHeight,handles.Para.FittingMaximumHeight)])
xlabel('z (um)');
ylabel('Averaged speed (um/s)');
legend('Samples','Samples for Fitting',['Polynomial Fitting with R^2:' num2str(RSQ,'%10.3f')],['Peak Value: ' num2str(pks,'%10.1f')]);
grid on;hold off;

handles=EnableButtomsEXE(handles);

SaveMean=strcat(handles.Para.Functions_FolderSaveName,'/AutoSaveMean.mat');
SaveSTDEV=strcat(handles.Para.Functions_FolderSaveName,'/AutoSaveStdev.mat');
DataSave_Mean=handles.Data.FlowVelocityProfile_mean;
DataSave_Stdev=handles.Data.FlowVelocityProfile_standdev;
save(SaveMean,'DataSave_Mean');
save(SaveSTDEV,'DataSave_Stdev');
% Update handles structure
guidata(hObject, handles);

function [handles,ValidTrackNum]=PlotScatterData(handles)
TotalTracks=length(handles.PostP_Inst.PostP_Data);
ValidTrackNum=1;
handles.Data.FlowVelocityProfile_mean=[];
handles.Data.FlowVelocityProfile_standdev=[];
handles.Data.FlowVelocityProfile_Trajecotries=[];
figure(handles.figure_flowprofile)
axes(handles.AXES_4DProfile);
for i=1:TotalTracks
    SampleData = handles.PostP_Inst.PostP_Data(i).data; 
    FrameNum=SampleData(:,1);
    XDATA=SampleData(:,2)*1e6;
    YDATA=SampleData(:,3)*1e6;
    ZDATA=SampleData(:,4)*1e6;
%     Valid=SampleData(:,5);
%     if(max(Valid(:))~=min(Valid(:)))
%         Valid=(Valid-min(Valid(:)))/(max(Valid(:))-min(Valid(:)))+0.1;
%     else
%         Valid=ones(size(Valid));
%     end
    MeanX=median(XDATA);
    ErrorX=std(XDATA);
    MeanY=median(YDATA);
    ErrorY=std(YDATA);
    MeanHeight=median(ZDATA);
    ErrorHeight=std(ZDATA);
    CORR_XY=[XDATA YDATA];
    %
    if(length(XDATA)>handles.Para.MinTrackSize && MeanHeight<handles.Para.MaximumHeight && MeanHeight>handles.Para.MinimumHeight)
        SPEED=zeros(size(CORR_XY,1),1);
        SPEED(1:end-1)=sqrt( ((CORR_XY(1:end-1,1,:)-CORR_XY(2:end,1,:))).^2 ...
           +(CORR_XY(1:end-1,2,:)-CORR_XY(2:end,2,:)).^2);
        SPEED(end)=SPEED(end-1);
        SPEED=SPEED*handles.Para.FrameRate;
        SPEEDMed=medfilt1(SPEED,handles.Para.SamplePoints);
        
        total_xy_distance_vector=CORR_XY(1,:)-CORR_XY(end,:);
        total_xy_distance=(total_xy_distance_vector(1)^2+total_xy_distance_vector(2)^2)^(0.5);
        ErrorSpeed=std(SPEEDMed);
         if(total_xy_distance<handles.Para.MinTravelDistance...
                 ||  ErrorHeight>handles.Para.StdevZ...
                 ||  ErrorX>handles.Para.StdevX...
                 ||  ErrorY>handles.Para.StdevY)
               continue 
         end  
        scatter3(XDATA,YDATA,ZDATA,[], SPEEDMed,'filled');hold on;
        handles.Data.FlowVelocityProfile_Trajecotries(end+1:end+length(SPEED),:)=[XDATA YDATA ZDATA SPEED];
        handles.Data.FlowVelocityProfile_mean(ValidTrackNum,:)=[MeanX MeanY MeanHeight median(SPEEDMed)];
        handles.Data.FlowVelocityProfile_error(ValidTrackNum,:)= ErrorHeight;
        handles.Data.FlowVelocityProfile_standdev(ValidTrackNum,:)=[ErrorX ErrorY ErrorHeight ErrorSpeed];
        handles.Data.HeightProfile_error(ValidTrackNum,:)=std(ZDATA(2:end));
        ValidTrackNum=ValidTrackNum+1;
    end
end


% --- Executes on button press in Buttom_LOADDATA.
function Buttom_LOADDATA_Callback(hObject, eventdata, handles)
% hObject    handle to Buttom_LOADDATA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=DisableButtomsEXE(handles);
% Update handles structure
guidata(hObject, handles);
pause(0.1); 
try 
    handles.PostP_Inst=CLASS_PostProcessing;
    handles.PostP_Inst.Load;   
    if(handles.PostP_Inst.PostP_DataSize~=0)
        set(handles.Button_Analyze,'Enable','on');
    else
        handles=DisableButtomsEXE(handles);
    end
catch

end
% Update handles structure
guidata(hObject, handles);


function PARA_FrameRate_Callback(hObject, eventdata, handles)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.Para.FrameRate));
    guidata(hObject, handles); 
    return
end
[FrameRate, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.Para.FrameRate));
    guidata(hObject, handles); 
    return
end
% Update Parameters (Configuration & instance)
handles.Para.FrameRate=FrameRate;

set(hObject,'String',num2str(handles.Para.FrameRate));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function PARA_FrameRate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PARA_MinTrackSize_Callback(hObject, eventdata, handles)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.Para.MinTrackSize));
    guidata(hObject, handles); 
    return
end
[MinTrackSize, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.Para.MinTrackSize));
    guidata(hObject, handles); 
    return
end
% Update Parameters (Configuration & instance)
handles.Para.MinTrackSize=MinTrackSize;

set(hObject,'String',num2str(handles.Para.MinTrackSize));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function PARA_MinTrackSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PARA_MaxHeight_Callback(hObject, eventdata, handles)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.Para.MaximumHeight));
    guidata(hObject, handles); 
    return
end
[MaximumHeight, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.Para.MaximumHeight));
    guidata(hObject, handles); 
    return
end
% Update Parameters (Configuration & instance)
handles.Para.MaximumHeight=MaximumHeight;

set(hObject,'String',num2str(handles.Para.MaximumHeight));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function PARA_MaxHeight_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PARA_MinHeight_Callback(hObject, eventdata, handles)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.Para.MinimumHeight));
    guidata(hObject, handles); 
    return
end
[MinimumHeight, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.Para.MinimumHeight));
    guidata(hObject, handles); 
    return
end
% Update Parameters (Configuration & instance)
handles.Para.MinimumHeight=MinimumHeight;

set(hObject,'String',num2str(handles.Para.MinimumHeight));
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function PARA_MinHeight_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PARA_MinTravelDistance_Callback(hObject, eventdata, handles)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.Para.MinTravelDistance));
    guidata(hObject, handles); 
    return
end
[MinTravelDistance, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.Para.MinTravelDistance));
    guidata(hObject, handles); 
    return
end
% Update Parameters (Configuration & instance)
handles.Para.MinTravelDistance=MinTravelDistance;

set(hObject,'String',num2str(handles.Para.MinTravelDistance));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function PARA_MinTravelDistance_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PARA_TravelStandardDevX_Callback(hObject, eventdata, handles)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.Para.StdevX));
    guidata(hObject, handles); 
    return
end
[Travelstd, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.Para.StdevX));
    guidata(hObject, handles); 
    return
end
% Update Parameters (Configuration & instance)
handles.Para.StdevX=Travelstd;

set(hObject,'String',num2str(handles.Para.StdevX));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function PARA_TravelStandardDevX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_TravelStandardDevX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Button_XZVIEW.
function Button_XZVIEW_Callback(hObject, eventdata, handles)
% hObject    handle to Button_XZVIEW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=DisableButtomsEXE(handles);
guidata(hObject, handles);
pause(0.1); 
% Calculate the data range for xz plane
FlowVelocityProfile_mean=handles.Data.FlowVelocityProfile_mean;
MaxA=max(FlowVelocityProfile_mean(:,1));
MinA=min(FlowVelocityProfile_mean(:,1));
MaxB=max(FlowVelocityProfile_mean(:,3));
MinB=min(FlowVelocityProfile_mean(:,3));
MaxS=max(FlowVelocityProfile_mean(:,2));
MinS=min(FlowVelocityProfile_mean(:,2));

if(handles.Para.XZViewYslicePosition==0)
    handles.Para.XZViewYslicePosition=round((MinS+MaxS)/2);
    set(handles.XZViewYslicePosition,'String',num2str(handles.Para.XZViewYslicePosition));
    guidata(hObject, handles);
    pause(0.1); 
end

[Xq,Yq,Zq] = meshgrid(round(MinA):1:round(MaxA),round(handles.Para.XZViewYslicePosition),round(MinB):1:round(MaxB));
disp('Please wait for analysis...')
Vq = griddata(handles.Data.FlowVelocityProfile_Trajecotries(:,1),...
             handles.Data.FlowVelocityProfile_Trajecotries(:,2),...
             handles.Data.FlowVelocityProfile_Trajecotries(:,3),...
             handles.Data.FlowVelocityProfile_Trajecotries(:,4),...
             Xq,Yq,Zq,'natural');
disp('Done!')

VqReshape=reshape(Vq,[size(Xq,2) size(Xq,3)]);
VqReshape=VqReshape';
figure(handles.figure_flowprofile)
axes(handles.AXES_Profile_Fitting);
mesh(VqReshape)
xlabel('x (um)')
ylabel('z (um)')
view([0,90]);
colormap(jet);
hcolor =colorbar;
hcolor.Label.String = 'Speed (um/s)';
grid on

handles=EnableButtomsEXE(handles);  
guidata(hObject, handles); 


% --- Executes on button press in ButtomYZView.
function ButtomYZView_Callback(hObject, eventdata, handles)
% hObject    handle to ButtomYZView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=DisableButtomsEXE(handles);
guidata(hObject, handles);
pause(0.1); 
% Calculate the data range for xz plane
FlowVelocityProfile_mean=handles.Data.FlowVelocityProfile_mean;
MaxA=max(FlowVelocityProfile_mean(:,2));
MinA=min(FlowVelocityProfile_mean(:,2));
MaxB=max(FlowVelocityProfile_mean(:,3));
MinB=min(FlowVelocityProfile_mean(:,3));
MaxS=max(FlowVelocityProfile_mean(:,1));
MinS=min(FlowVelocityProfile_mean(:,1));

if(handles.Para.YZViewXslicePosition==0)
    handles.Para.YZViewXslicePosition=round((MinS+MaxS)/2);
    set(handles.YZViewXslicePosition,'String',num2str(handles.Para.YZViewXslicePosition));
    guidata(hObject, handles);
    pause(0.1); 
end
[Xq,Yq,Zq] = meshgrid(round(handles.Para.YZViewXslicePosition),round(MinA):1:round(MaxA),round(MinB):1:round(MaxB));

disp('Please wait for analysis...')
Vq = griddata(handles.Data.FlowVelocityProfile_Trajecotries(:,1),...
             handles.Data.FlowVelocityProfile_Trajecotries(:,2),...
             handles.Data.FlowVelocityProfile_Trajecotries(:,3),...
             handles.Data.FlowVelocityProfile_Trajecotries(:,4),...
             Xq,Yq,Zq,'natural');
disp('Done!')

VqReshape=reshape(Vq,[size(Xq,1) size(Xq,3)]);
VqReshape=VqReshape';
figure(handles.figure_flowprofile)
axes(handles.AXES_Profile_Fitting);
mesh(VqReshape)
xlabel('y (um)')
ylabel('z (um)')
view([0,90]);
colormap(jet);
hcolor =colorbar;
hcolor.Label.String = 'Speed (um/s)';
grid on

handles=EnableButtomsEXE(handles);  
guidata(hObject, handles); 

% --- Executes on button press in ButtomXYZView.
function ButtomXYZView_Callback(hObject, eventdata, handles)
% hObject    handle to ButtomXYZView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=DisableButtomsEXE(handles);
guidata(hObject, handles);
pause(0.1); 

[handles,ValidTrackNum]=PlotScatterData(handles);
figure(handles.figure_flowprofile)
axes(handles.AXES_4DProfile);
xlabel('x (um)');
ylabel('y (um)');
zlabel('z (um)');
zlim([handles.Para.MinimumHeight handles.Para.MaximumHeight])
colormap(jet);
hcolor =colorbar;
hcolor.Label.String = 'Speed (um/s)';
hold off;

FlowHeight_vs_VelocityProfile_mean=handles.Data.FlowVelocityProfile_mean(:,3:4);
[~,I] = sort(FlowHeight_vs_VelocityProfile_mean(:,1));
ProfileData=zeros(size(FlowHeight_vs_VelocityProfile_mean));
ProfileVelocityERROR=zeros(size(handles.Data.FlowVelocityProfile_error));
for i_sort=1:ValidTrackNum-1
     ProfileData(i_sort,:)=FlowHeight_vs_VelocityProfile_mean(I(i_sort),:);
     ProfileVelocityERROR(i_sort)=handles.Data.FlowVelocityProfile_error(I(i_sort));
end
bin=handles.Para.BinNumber;
interval=round(max(ProfileData(:,1))/bin);
LowL=min(handles.Para.MinimumHeight,handles.Para.FittingMinimumHeight);
HighL=max(handles.Para.MaximumHeight,handles.Para.FittingMaximumHeight);

for i_sort=1:ValidTrackNum-1
   if ProfileData(i_sort,1)>=handles.Para.FittingMinimumHeight
       SampleFitLow=i_sort;
       break;
   end
end
for i_sort=ValidTrackNum-1:-1:1
   if ProfileData(i_sort,1)<=handles.Para.FittingMaximumHeight
       SampleFitHigh=i_sort;
       break;
   end
end

Fitting_X = LowL:interval:HighL;
inc=1;
i_add=1;
SampleN=zeros(size(Fitting_X));
Profile_Std_SampleError=zeros(size(Fitting_X));
for i_error=LowL:interval:HighL
    HeightLevel=i_error;
    while(ProfileData(inc,1)<HeightLevel+0.5)
        Profile_Std_SampleError(i_add)=ProfileVelocityERROR(inc)+Profile_Std_SampleError(i_add);
        SampleN(i_add)=SampleN(i_add)+1;
        if(inc>=ValidTrackNum-1)
            break;
        end
        inc=inc+1;
    end
    i_add=i_add+1;
end
Profile_Std_SampleError=Profile_Std_SampleError./(1+SampleN);

figure(handles.figure_flowprofile)
axes(handles.AXES_Profile_Fitting);
plot(ProfileData(:,1),ProfileData(:,2),'.k','MarkerSize',10);hold on;
plot(ProfileData(SampleFitLow:SampleFitHigh,1),ProfileData(SampleFitLow:SampleFitHigh,2),'.b','MarkerSize',10);
PARA_Fit = polyfit(ProfileData(SampleFitLow:SampleFitHigh,1),ProfileData(SampleFitLow:SampleFitHigh,2),handles.Para.FittingOrder);
Yresidual= ProfileData(SampleFitLow:SampleFitHigh,2)-polyval(PARA_Fit,ProfileData(SampleFitLow:SampleFitHigh,1));
Sresidual=sum(Yresidual.^2);
SStotal = (length(ProfileData(SampleFitLow:SampleFitHigh,2))-1) * var(ProfileData(SampleFitLow:SampleFitHigh,2));
RSQ = 1 - Sresidual/SStotal;
Fitting_Y = polyval(PARA_Fit,Fitting_X);
errorbar(Fitting_X,Fitting_Y,Profile_Std_SampleError,'-k','MarkerSize',10,'LineWidth',1);hold on;
[pks,locs] =findpeaks(Fitting_Y,Fitting_X);
plot(locs,pks,'or','MarkerSize',10);hold on;
xlim([min(handles.Para.MinimumHeight,handles.Para.FittingMinimumHeight), max(handles.Para.MaximumHeight,handles.Para.FittingMaximumHeight)])
xlabel('z (um)');
ylabel('Averaged speed (um/s)');
legend('Samples','Samples for Fitting',['Polynomial Fitting with R^2:' num2str(RSQ,'%10.3f')],['Peak Value: ' num2str(pks,'%10.1f')]);
grid on;hold off;

handles=EnableButtomsEXE(handles);
% Update handles structure
guidata(hObject, handles);

function PARA_Fitting_minDist_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Fitting_minDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.Para.FittingMinimumHeight));
    guidata(hObject, handles); 
    return
end
[Fitting_minDist, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.Para.FittingMinimumHeight));
    guidata(hObject, handles); 
    return
end
% Update Parameters (Configuration & instance)
if(Fitting_minDist>=handles.Para.MaximumHeight || Fitting_minDist>=handles.Para.FittingMaximumHeight)
    return
end
handles.Para.FittingMinimumHeight=Fitting_minDist;

set(hObject,'String',num2str(handles.Para.FittingMinimumHeight));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function PARA_Fitting_minDist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Fitting_minDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PARA_Fitting_maxDist_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_Fitting_maxDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes during object creation, after setting all properties.

Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.Para.FittingMaximumHeight));
    guidata(hObject, handles); 
    return
end
[Fitting_maxDist, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.Para.FittingMaximumHeight));
    guidata(hObject, handles); 
    return
end
% Update Parameters (Configuration & instance)
if(Fitting_maxDist<=handles.Para.MinimumHeight || Fitting_maxDist<=handles.Para.FittingMinimumHeight)
    return
end
handles.Para.FittingMaximumHeight=Fitting_maxDist;

set(hObject,'String',num2str(handles.Para.FittingMaximumHeight));
guidata(hObject, handles);

function PARA_Fitting_maxDist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_Fitting_maxDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PARA_FittingOrder_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_FittingOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.Para.FittingOrder));
    guidata(hObject, handles); 
    return
end
[Fitting_order, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.Para.FittingOrder));
    guidata(hObject, handles); 
    return
end
% Update Parameters (Configuration & instance)
if(Fitting_order~=1 && Fitting_order~=2)
    set(hObject,'String',num2str(handles.Para.FittingOrder));
    guidata(hObject, handles); 
    return
end
handles.Para.FittingOrder=Fitting_order;
set(hObject,'String',num2str(handles.Para.FittingOrder));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function PARA_FittingOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_FittingOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PARA_FittingBins_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_FittingBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.Para.BinNumber));
    guidata(hObject, handles); 
    return
end
[Fitting_bin, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.Para.BinNumber));
    guidata(hObject, handles); 
    return
end
% Update Parameters (Configuration & instance)
if(handles.Para.BinNumber<1)
    set(hObject,'String',num2str(handles.Para.BinNumber));
    guidata(hObject, handles); 
    return
end
handles.Para.BinNumber=Fitting_bin;
set(hObject,'String',num2str(handles.Para.BinNumber));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function PARA_FittingBins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_FittingBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PARA_TravelStandardDevY_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_TravelStandardDevY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.Para.StdevY));
    guidata(hObject, handles); 
    return
end
[Travelstd, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.Para.StdevY));
    guidata(hObject, handles); 
    return
end
% Update Parameters (Configuration & instance)
handles.Para.StdevY=Travelstd;

set(hObject,'String',num2str(handles.Para.StdevY));
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function PARA_TravelStandardDevY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_TravelStandardDevY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PARA_TravelStandardDevZ_Callback(hObject, eventdata, handles)
% hObject    handle to PARA_TravelStandardDevZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.Para.StdevZ));
    guidata(hObject, handles); 
    return
end
[Travelstd, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.Para.StdevZ));
    guidata(hObject, handles); 
    return
end
% Update Parameters (Configuration & instance)
handles.Para.StdevZ=Travelstd;

set(hObject,'String',num2str(handles.Para.StdevZ));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function PARA_TravelStandardDevZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PARA_TravelStandardDevZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XZViewYslicePosition_Callback(hObject, eventdata, handles)
% hObject    handle to XZViewYslicePosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.Para.XZViewYslicePosition));
    guidata(hObject, handles); 
    return
end
[ysclicePosition, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.Para.XZViewYslicePosition));
    guidata(hObject, handles); 
    return
end
% Update Parameters (Configuration & instance)
handles.Para.XZViewYslicePosition=ysclicePosition;
set(hObject,'String',num2str(handles.Para.XZViewYslicePosition));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function XZViewYslicePosition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XZViewYslicePosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YZViewXslicePosition_Callback(hObject, eventdata, handles)
% hObject    handle to YZViewXslicePosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.Para.YZViewXslicePosition));
    guidata(hObject, handles); 
    return
end
[xsclicePosition, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.Para.YZViewXslicePosition));
    guidata(hObject, handles); 
    return
end
% Update Parameters (Configuration & instance)
handles.Para.YZViewXslicePosition=xsclicePosition;
set(hObject,'String',num2str(handles.Para.YZViewXslicePosition));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function YZViewXslicePosition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YZViewXslicePosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in XZ_Averaged.
function XZ_Averaged_Callback(hObject, eventdata, handles)
% hObject    handle to XZ_Averaged (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=DisableButtomsEXE(handles);
guidata(hObject, handles);
pause(0.1); 

% Set data 
FlowVelocityProfile_mean=handles.Data.FlowVelocityProfile_mean;
FlowVelocityProfile_Stdev=handles.Data.FlowVelocityProfile_standdev;
TrackData=[FlowVelocityProfile_mean(:,3) FlowVelocityProfile_mean(:,1)];
MaxA=max(FlowVelocityProfile_mean(:,1));
MinA=min(FlowVelocityProfile_mean(:,1));
MaxB=max(FlowVelocityProfile_mean(:,3));
MinB=min(FlowVelocityProfile_mean(:,3));
Xstdev=FlowVelocityProfile_Stdev(:,1);
Zstdev=FlowVelocityProfile_Stdev(:,3);
Speedstdev=FlowVelocityProfile_Stdev(:,4);

% scatter plot
figure(handles.figure_flowprofile)
axes(handles.AXES_Profile_Fitting);
scatter3(TrackData(:,2),TrackData(:,1),FlowVelocityProfile_mean(:,4),20,FlowVelocityProfile_mean(:,4))
xlabel('y (um)')
ylabel('z (um)')
zlabel('Speed (um/s)')
view([0,90]);
colormap(jet);
hcolor =colorbar;
hcolor.Label.String = 'Speed (um/s)';
grid on

% Interpolated plot
[Aq,Bq] = meshgrid(round(MinA):1:round(MaxA), round(MinB):1:round(MaxB));
Vq = griddata(TrackData(:,2),TrackData(:,1),FlowVelocityProfile_mean(:,4),Aq,Bq,'cubic');
B = medfilt2(Vq, [handles.binSize handles.binSize],'symmetric');
figure(handles.figure_flowprofile)
axes(handles.AXES_4DProfile);
mesh(Aq,Bq,B);
xlabel('y (um)')
ylabel('z (um)')
zlabel('Speed (um/s)')
view([0,90]);
colormap(jet);
hcolor =colorbar;
hcolor.Label.String = 'Speed (um/s)';

% Stdev
[AqLW,BqLW] = meshgrid(round(MinA):round((MaxA-MinA)/handles.binSize):round(MaxA),round(MinB):round((MaxB-MinB)/handles.binSize):round(MaxB));
ShowSTDEVINFIGURE(FlowVelocityProfile_mean,Xstdev,Zstdev,Speedstdev,Aq,Bq,AqLW,BqLW,TrackData,handles.binSize,'x','z');

handles=EnableButtomsEXE(handles);
guidata(hObject, handles);

% --- Executes on button press in YZ_Averaged.
function YZ_Averaged_Callback(hObject, eventdata, handles)
% hObject    handle to YZ_Averaged (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=DisableButtomsEXE(handles);
guidata(hObject, handles);
pause(0.1); 
  
FlowVelocityProfile_mean=handles.Data.FlowVelocityProfile_mean;
figure(handles.figure_flowprofile)
axes(handles.AXES_Profile_Fitting);
TrackData=[FlowVelocityProfile_mean(:,3) FlowVelocityProfile_mean(:,2)];
MaxA=max(FlowVelocityProfile_mean(:,2));
MinA=min(FlowVelocityProfile_mean(:,2));
MaxB=max(FlowVelocityProfile_mean(:,3));
MinB=min(FlowVelocityProfile_mean(:,3));
scatter3(TrackData(:,2),TrackData(:,1),FlowVelocityProfile_mean(:,4),20,FlowVelocityProfile_mean(:,4))
xlabel('y (um)')
ylabel('z (um)')
zlabel('Speed (um/s)')
view([0,90]);
colormap(jet);
hcolor =colorbar;
hcolor.Label.String = 'Speed (um/s)';
grid on

[Aq,Bq] = meshgrid(round(MinA):1:round(MaxA), round(MinB):1:round(MaxB));
Vq = griddata(TrackData(:,2),TrackData(:,1),FlowVelocityProfile_mean(:,4),Aq,Bq,'cubic');
B = medfilt2(Vq, [handles.binSize handles.binSize],'symmetric');
figure(handles.figure_flowprofile)
axes(handles.AXES_4DProfile);
mesh(Aq,Bq,B);
xlabel('y (um)')
ylabel('z (um)')
zlabel('Speed (um/s)')
view([0,90]);
colormap(jet);
hcolor =colorbar;
hcolor.Label.String = 'Speed (um/s)';

[AqLW,BqLW] = meshgrid(round(MinA):round((MaxA-MinA)/handles.binSize):round(MaxA),round(MinB):round((MaxB-MinB)/handles.binSize):round(MaxB));
FlowVelocityProfile_Stdev=handles.Data.FlowVelocityProfile_standdev;
Ystdev=FlowVelocityProfile_Stdev(:,2);
Zstdev=FlowVelocityProfile_Stdev(:,3);
Speedstdev=FlowVelocityProfile_Stdev(:,4);
ShowSTDEVINFIGURE(FlowVelocityProfile_mean,Ystdev,Zstdev,Speedstdev,Aq,Bq,AqLW,BqLW,TrackData,handles.binSize,'y','z');

handles=EnableButtomsEXE(handles);
guidata(hObject, handles);

function ShowSTDEVINFIGURE(FlowVelocityProfile_mean,Astdev,Bstdev,Cstdev,Xq,Yq,XqLW,YqLW,TrackData,binSize,AxisXName,AxisYName)
[binX,binY]=size(XqLW);
LocalWeight=hist3(TrackData,'Nbins',[binX binY]);
InterpolatedDensity = griddata(XqLW,YqLW,LocalWeight,Xq,Yq,'cubic');
InterpolatedDensity = medfilt2(InterpolatedDensity, [binSize binSize],'symmetric');
f2h=figure(2);
set(f2h,'NumberTitle','off');
set(f2h,'Name','Distribution of Standard Deviation and Particle Density Histogram');
set(f2h,'Position',[100 100 1024 800]);
subplot(2,3,1)
scatter3(FlowVelocityProfile_mean(:,2),FlowVelocityProfile_mean(:,3),Astdev,20,Astdev);
view([0,90]);
zlim([0 2]);
title(['Standard Deviation in ',AxisXName, ' direction'])
subplot(2,3,4)
YstdevInterp = griddata(FlowVelocityProfile_mean(:,2),FlowVelocityProfile_mean(:,3),Astdev,Xq,Yq,'cubic');
YstdevInterp = medfilt2(YstdevInterp, [binSize binSize],'symmetric');
mesh(Xq,Yq,YstdevInterp);
view([0,90]);
title('Standard Deviation (Interpolation)')
subplot(2,3,2)
scatter3(FlowVelocityProfile_mean(:,2),FlowVelocityProfile_mean(:,3),Bstdev,20,Bstdev);
view([0,90]);
zlim([0 2]);
title(['Standard Deviation in ',AxisYName, ' direction'])
subplot(2,3,5)
ZstdevInterp = griddata(FlowVelocityProfile_mean(:,2),FlowVelocityProfile_mean(:,3),Bstdev,Xq,Yq,'cubic');
ZstdevInterp = medfilt2(ZstdevInterp, [binSize binSize],'symmetric');
mesh(Xq,Yq,ZstdevInterp);
view([0,90]);
title('Standard Deviation (Interpolation)')
subplot(2,3,3)
scatter3(FlowVelocityProfile_mean(:,2),FlowVelocityProfile_mean(:,3),Cstdev,20,Cstdev);
view([0,90]);
title('Standard Deviation for Speed Estimation')
subplot(2,3,6)
mesh(InterpolatedDensity);colormap(jet);set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
view([0,90]);
title('Particle Density histogram')


% --- Executes on button press in XYView.
function XYView_Callback(hObject, eventdata, handles)
% hObject    handle to XYView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=DisableButtomsEXE(handles);
guidata(hObject, handles);
pause(0.1); 
% Calculate the data range for xz plane
FlowVelocityProfile_mean=handles.Data.FlowVelocityProfile_mean;
MaxA=max(FlowVelocityProfile_mean(:,1));
MinA=min(FlowVelocityProfile_mean(:,1));
MaxB=max(FlowVelocityProfile_mean(:,2));
MinB=min(FlowVelocityProfile_mean(:,2));
MaxS=max(FlowVelocityProfile_mean(:,3));
MinS=min(FlowVelocityProfile_mean(:,3));

if(handles.Para.XYViewZslicePosition==0)
    handles.Para.XYViewZslicePosition=round((MinS+MaxS)/2);
    set(handles.XYViewZslicePosition,'String',num2str(handles.Para.XYViewZslicePosition));
    guidata(hObject, handles);
    pause(0.1); 
end
[Xq,Yq,Zq] = meshgrid(round(MinA):1:round(MaxA),round(MinB):1:round(MaxB),round(handles.Para.XYViewZslicePosition));

disp('Please wait for analysis...')
Vq = griddata(handles.Data.FlowVelocityProfile_Trajecotries(:,1),...
             handles.Data.FlowVelocityProfile_Trajecotries(:,2),...
             handles.Data.FlowVelocityProfile_Trajecotries(:,3),...
             handles.Data.FlowVelocityProfile_Trajecotries(:,4),...
             Xq,Yq,Zq,'natural');
disp('Done!')

VqReshape=reshape(Vq,[size(Xq,1) size(Xq,2)]);
VqReshape=VqReshape';
figure(handles.figure_flowprofile)
axes(handles.AXES_Profile_Fitting);
mesh(VqReshape)
xlabel('x (um)')
ylabel('y (um)')
view([0,90]);
colormap(jet);
hcolor =colorbar;
hcolor.Label.String = 'Speed (um/s)';
grid on

handles=EnableButtomsEXE(handles);  
guidata(hObject, handles); 

function XYViewZslicePosition_Callback(hObject, eventdata, handles)
% hObject    handle to XYViewZslicePosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Numstring=get(hObject,'String');
if(isempty(Numstring))
    set(hObject,'String',num2str(handles.Para.XYViewZslicePosition));
    guidata(hObject, handles); 
    return
end
[zsclicePosition, status] = str2num(Numstring);
if(status==0)
    set(hObject,'String',num2str(handles.Para.XYViewZslicePosition));
    guidata(hObject, handles); 
    return
end
% Update Parameters (Configuration & instance)
handles.Para.XYViewZslicePosition=zsclicePosition;
set(hObject,'String',num2str(handles.Para.XYViewZslicePosition));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function XYViewZslicePosition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XYViewZslicePosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles=DisableButtomsEXE(handles)
set(handles.ButtomXYZView,'Enable','off');
set(handles.Button_XZVIEW,'Enable','off');
set(handles.ButtomYZView,'Enable','off');
set(handles.XYView,'Enable','off');
set(handles.XZ_Averaged,'Enable','off');
set(handles.YZ_Averaged,'Enable','off');
set(handles.Button_Analyze,'Enable','off');
set(handles.XZViewYslicePosition,'Enable','off');
set(handles.YZViewXslicePosition,'Enable','off');
set(handles.XYViewZslicePosition,'Enable','off');

function handles=EnableButtomsEXE(handles)
set(handles.ButtomXYZView,'Enable','on');
set(handles.Button_XZVIEW,'Enable','on');
set(handles.ButtomYZView,'Enable','on');
set(handles.XYView,'Enable','on');
set(handles.XZ_Averaged,'Enable','on');
set(handles.YZ_Averaged,'Enable','on');
set(handles.Button_Analyze,'Enable','on');
set(handles.XZViewYslicePosition,'Enable','on');
set(handles.YZViewXslicePosition,'Enable','on');
set(handles.XYViewZslicePosition,'Enable','on');
