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
function Configuration=GUI_DHMTrack_initialization()
 %% Parallel computing
   Configuration.GPUConfig.Active=0;
   Configuration.CPUConfig.ParForActive=0;
   Configuration.CPUConfig.Cores=4;
 %% Main parameters
    Configuration.PreProcessConfig.ActivateROI='Off';
    Configuration.PreProcessConfig.ROI=[];
    Configuration.PreProcessConfig.BoundaryEdge=0;
    Configuration.PreProcessConfig.Backgroundsubtraction='Off';
    Configuration.PreProcessConfig.Backgroundnorm='Off';
    Configuration.PreProcessConfig.BackgroundsubtractionMethod='Static'; %'Moving'
    Configuration.PreProcessConfig.BackgroundImage=[];
    Configuration.PreProcessConfig.BackgroundHolograph=[];
    Configuration.PreProcessConfig.Backgroundframes=1;
    Configuration.PreProcessConfig.Channel=0; % 0 gray 1 R 2 G 3 B
    Configuration.PreProcessConfig.IntensityRescaling='Off';
    Configuration.PreProcessConfig.Resize.On=0;
    Configuration.PreProcessConfig.Resize.Num=1;
    Configuration.PreProcessConfig.Gaussian.On=1;
    Configuration.PreProcessConfig.Gaussian.KernelSize=3;
    Configuration.PreProcessConfig.Gaussian.Variance=0.8;
    %% Detection   
    Configuration.DetectionConfig.Resize.Num=1;
    Configuration.DetectionConfig.Method.ITTrans.ScaleNum=2;
    Configuration.DetectionConfig.Method.ITTrans.MappingRadius=2;
    Configuration.DetectionConfig.Method.ITTrans.MaxSize=2000;
    Configuration.DetectionConfig.Method.ITTrans.MinSize=4;
    Configuration.DetectionConfig.Method.ITTrans.ITThresh=0.1;
    Configuration.DetectionConfig.Method.ITTrans.MinVotes=10;
    Configuration.DetectionConfig.Method.ITTrans.LineLength=10;
    Configuration.DetectionConfig.Method.ITTrans.Iteration=3;
    Configuration.DetectionConfig.Method.Name='Cell'; % Manual ITTrans Cell
    Configuration.DetectionConfig.Method.Cell.Threshold=[];
    Configuration.DetectionConfig.Method.ManualSelection=1;
    Configuration.DetectionConfig.Method.Steps=20000;
    Configuration.DetectionConfig.Method.MinSize=200;
    Configuration.DetectionConfig.Method.MaxSize=10000;
    Configuration.DetectionConfig.Method.BinaryMaskLevel=0.5;
    Configuration.DetectionConfig.Method.Gaussian =0;
    Configuration.DetectionConfig.Method.GaussianK=1.0;
    Configuration.DetectionConfig.Method.HighPass=0;
    Configuration.DetectionConfig.Method.EdgeThresh=4;
    Configuration.DetectionConfig.Method.MorphSize=3;
    Configuration.DetectionConfig.Method.RemoveFP.Polyfit=1;
    Configuration.DetectionConfig.Method.RemoveFP.DistCostMatrix=1;
    Configuration.DetectionConfig.Method.RemoveFP.MaxDist=10;
    %% Tracking
    Configuration.TrackingConfig.Method='Kalman';
    Configuration.TrackingConfig.FixedTemplate=1;
    Configuration.TrackingConfig.FixedTemplateSize=150;
    Configuration.TrackingConfig.NN.TrackingROI='Off';
    Configuration.TrackingConfig.NN.LocalDetection=0;
    Configuration.TrackingConfig.NN.ITTracking=Configuration.DetectionConfig.Method.ITTrans;
    Configuration.TrackingConfig.NN.ApplyRange=150;
    Configuration.TrackingConfig.NN.NumOfTracks=20000;
    Configuration.TrackingConfig.NN.MaxDisplacement=150;
    Configuration.TrackingConfig.NN.MaxSizeDiff=50;
    Configuration.TrackingConfig.NN.MatchingThresh=0.5;
    Configuration.TrackingConfig.NN.CostOfNonAssignment=200;
    Configuration.TrackingConfig.NN.AgeLine= 3;
    Configuration.TrackingConfig.NN.VisibilityThresholdBelowLine=1;
    Configuration.TrackingConfig.NN.VisibilityThresholdAboveLine=0.2;
    Configuration.TrackingConfig.KNN.Active=0;
    Configuration.TrackingConfig.K.MotionModel='ConstantAcceleration';
    Configuration.TrackingConfig.K.InitialEstimateError=[1 1 1]*1e5;
    Configuration.TrackingConfig.K.MotionNoise=[Configuration.TrackingConfig.NN.MaxDisplacement Configuration.TrackingConfig.NN.MaxDisplacement*0.25 Configuration.TrackingConfig.NN.MaxDisplacement*0.25];
    Configuration.TrackingConfig.K.MeasurementNoise=Configuration.TrackingConfig.NN.MaxDisplacement*0.5;
    %% Refine
    Configuration.RefinementConfig.Resample.Active=1;
    Configuration.RefinementConfig.Resample.Interp='off';
    Configuration.RefinementConfig.Resample.Pattern='Sector'; % Circular
    Configuration.RefinementConfig.RefineCenter.Active.XCORR=0;
    Configuration.RefinementConfig.RefineCenter.Active.CSYM=0;
    Configuration.RefinementConfig.RefineCenter.Range=10;
    Configuration.RefinementConfig.RefineCenter.XCorr.LowRange=0.4; %  0<x<0.5
    Configuration.RefinementConfig.RefineCenter.XCorr.HighRange=0.6; %  0.5<x<1
    Configuration.RefinementConfig.RefineCenter.XCorr.MedianFilter=1;
    Configuration.RefinementConfig.RefineCenter.ISYM.MedianFilter=1;
    %% Reconstruct
    Configuration.ReconstructConfig.Active=1;
    Configuration.ReconstructConfig.Method='1D'; % 1D 1DDecov 2D
    Configuration.ReconstructConfig.Basic.ParaxialMask = 0; % 0 >0
    Configuration.ReconstructConfig.Basic.ImageResize = 1;
    Configuration.ReconstructConfig.Basic.TemplateResize=1; % >1
    Configuration.ReconstructConfig.Basic.Wavelength=0.47e-6; % 1.50 1.33800553 0.2e-6, 0.470e-6
    Configuration.ReconstructConfig.Basic.RefractiveIndex=1.33;
    Configuration.ReconstructConfig.Basic.Lambda=Configuration.ReconstructConfig.Basic.Wavelength/Configuration.ReconstructConfig.Basic.RefractiveIndex; 
    Configuration.ReconstructConfig.Basic.PixelSpacing=0.132e-6; % CCD size/pixel num/Magnification 0.04e-6
    Configuration.ReconstructConfig.Basic.StepSize= 1;
    Configuration.ReconstructConfig.Basic.StartStep=1;
    Configuration.ReconstructConfig.Basic.StopStep=400; % 105 um for 0.35e-6 lambda
    Configuration.ReconstructConfig.Basic.WindowSizeFactor=1; % >2, low pass
    Configuration.ReconstructConfig.Basic.HistEqual='Off'; %
    Configuration.ReconstructConfig.ConvertZ=1/(Configuration.ReconstructConfig.Basic.ImageResize)*...
    Configuration.ReconstructConfig.Basic.StepSize*...
    Configuration.ReconstructConfig.Basic.Lambda;
    % Initialized the track
    Configuration.AvailableTracksList=1:Configuration.TrackingConfig.NN.NumOfTracks;
    %%
    Configuration.OutputConfig.PathResults='AutoSave\';
    Configuration.OutputConfig.PathDetection=...
        strcat(Configuration.OutputConfig.PathResults,'Detection\');
    Configuration.OutputConfig.PathTracking=...
        strcat(Configuration.OutputConfig.PathResults,'Tracking\');
    Configuration.OutputConfig.WriteFrame=0;
    Configuration.OutputConfig.PresentTrack=1;
    Configuration.OutputConfig.PresentReconstruction=0;
    %% For debugging
    Configuration.OutputConfig.Fig1=[];
    Configuration.OutputConfig.Fig2=[];

end
