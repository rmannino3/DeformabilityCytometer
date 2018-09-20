function [indCellTracks,falseCapture,cellVelocities,effectiveDiamaters] = Cell_Counter_Final()
%Takes Text Files from UMUTracker, and Organizes Data
%Puneeth Guruprasad - 2/2/2018


% --------------------------------------------------------------------------
[FileName,PathName,FilterIndex] = uigetfile('.txt','Choose text files of cell tracks','MultiSelect','on');

%Ask for User Input - Nanometer to Pixel Ratio (Numerical Input)

prompt = {'Enter the Nanometer to Pixel Ratio of the Video Sample:','Enter the Frame Rate of the Camera:'};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'522','9.69'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
nm2pix = str2num(answer{1}); %already taken into account in the interface
frameRate = str2num(answer{2}); %should be placed in

% --------------------------------------------------------------------------
%Convert Raw Text Files from UMU Tracker into Cell Array of Cell Positions
rawTextFiles = [];
arr = [];
for i = 1:length(FileName)
    
A = FileName{i};
fileID = fopen(A,'r');
out = textscan(fileID,'%f');
C = out{1};

for j = 1:6:length(C)
    vec = [C(j) C(j+1) C(j+2) C(j+3) C(j+4) C(j+5)];   
    arr = [arr;vec];
end
arr = {arr};
rawTextFiles = [rawTextFiles arr];
arr = [];

fclose(fileID);
end
indCellTracks = rawTextFiles;

% --------------------------------------------------------------------------
%Clean Data - Remove All Single Position Files
indCellTracks_Clean = [];
falseCapture = 0;
cleanLog = false([1 length(indCellTracks)]);
for i = 1:length(indCellTracks)
   cell = indCellTracks{i};
   [r,c] = size(cell);
  
    xStart = cell(1,2);
    xFinish = cell(r,2);
    xLength = xFinish-xStart;
  
  if r == 1 || r == 2 || xLength < 5*10^(-5) %Cell Has to Travel at Least 50um
  falseCapture  = falseCapture + 1;
  else
  cleanLog(i) = true;
  end
 
end
indCellTracks_Clean = indCellTracks(cleanLog);


% --------------------------------------------------------------------------
% Extract Distances Travelled in X and #Frames Captured 
% Combine this information with "Frame Rate" of camera
% EDIT: 6/18 - Check Major and Minor Axis
framesCaptured = [];
xDisplacements = [];
effectiveDiamaters = [];
majorAxes = []


for i = 1:length(indCellTracks_Clean)
     cell = indCellTracks_Clean{i};
    [r,c] = size(cell);
  
    xStart = cell(1,2);
    xFinish = cell(r,2);
    xLength = xFinish-xStart;
    
    majorAxis = cell(:,5);
    minorAxis = cell(:,6); 
    
    diameterVec = (majorAxis+minorAxis)./2; %list of diamaters within the channel
    diam = mean(diameterVec);
    
    
    framesCaptured = [framesCaptured r];
    xDisplacements = [xDisplacements xLength];

    effectiveDiamaters = [effectiveDiamaters diam];
    %majorAxes = [majorAxes majorAxis];
      
end

cellTrackingTimes = framesCaptured./frameRate;
% --------------------------------------------------------------------------
% Run through raw data and check for single tracks that were fragmented
% (A cell tracked multiple times through the course of its transit will be
% displayed as individual tracks)
% This attempts to recover potentially ignored data
% Add '{' below to mute this section
%{ 

uncleanData = indCellTracks(~cleanLog);
fragArr = []; 

for i = 1:length(uncleanData)
    vec = uncleanData{i}
    fragArr = [fragArr;vec]
    
end

yPos = fragArr(:,3);
diffs = abs(diff(yPos));
logU2C = diffs < 1E-4 % Guessing error threshold/variation

v1 = (logU2C(:)==1);
d = diff(v1);
pos = [find([v1(1);d]==1) find([d;-v1(end)]==-1)];

pos(:,2) = pos(:,2)+1;

[r c] = size(pos);
fragX = fragArr(:,2);
fragFramesCaptured = [];
fragDisplacements = [];

for j=1:r
   startF = pos(j,1);
   endF = pos(j,2);
   
   xStart = fragX(startF);
   xFinish = fragX(endF);
   
   xLength = xFinish - xStart;
    
   fragDisplacements = [fragDisplacements xLength]; 
   
   numFrames = endF-startF+1;
   fragFramesCaptured = [fragFramesCaptured numFrames];
end

fragTrackingTimes = fragFramesCaptured./frameRate;


xDisplacements = [xDisplacements fragDisplacements];
cellTrackingTimes = [cellTrackingTimes fragTrackingTimes];

%}
% --------------------------------------------------------------------------
%Eliminate False Positives / Poor Tracks
mask = xDisplacements > 0;
xDisplacements = xDisplacements(mask);
cellTrackingTimes = cellTrackingTimes(mask);

effectiveDiamaters = effectiveDiamaters(mask);
%majorAxes = majorAxes(mask);



%Calculate Average Velcoties of Cells [nm / s]
cellVelocities = xDisplacements./cellTrackingTimes*10^6;




end

