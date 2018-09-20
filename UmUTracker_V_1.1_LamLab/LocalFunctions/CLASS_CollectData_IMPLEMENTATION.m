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
classdef CLASS_CollectData_IMPLEMENTATION < CLASS_CollectData_INTERFACE
    
    methods
        function obj=CLASS_CollectData_IMPLEMENTATION(Config)
            if(nargin>0)
                 obj.DataConfig=Config.OutputConfig;
            else
                disp('Default Saving Path:AutoSave')
                obj.DataConfig.PathResults='AutoSave\';
                obj.DataConfig.PathDetection=...
                    strcat(obj.DataConfig.PathResults,'Images\');
                obj.DataConfig.PathTracking=...
                    strcat(obj.DataConfig.PathResults,'Tracks\');
            end   
            mkdir(obj.DataConfig.PathDetection);
            mkdir(obj.DataConfig.PathTracking);
        end
        
        function  obj=Update(obj)
            obj.DataConfig.PathDetection=...
                    strcat(obj.DataConfig.PathResults,'Images\');
            obj.DataConfig.PathTracking=...
                    strcat(obj.DataConfig.PathResults,'Tracks\');
            mkdir(obj.DataConfig.PathDetection);
            mkdir(obj.DataConfig.PathTracking);
        end
        
        function obj=Collect(obj,Tracks,TracksConfig,ConversionFactorXY,FrameIndex,Detection) 
            obj.Results={};
            obj.DataConfig.Tracking=TracksConfig;
            for i=1:length(Tracks)
                    obj.Results(i).ConversionFactor=ConversionFactorXY;
                    obj.Results(i).Id=Tracks(i).Id;
                    obj.Results(i).Frame=FrameIndex;
                    obj.Results(i).Centroid=Tracks(i).Centroid;
                    obj.Results(i).ZPos=Tracks(i).ZPos;
                    obj.Results(i).Radius=Tracks(i).Radius;
                    InstantVelocityVector=Tracks(i).Centroid-Tracks(i).LastVisible;
                    %obj.Results(i).Direction=atan(InstantVelocityVector(2) / InstantVelocityVector(1));
                    %obj.Results(i).MeanSpeed=norm(Tracks(i).FirstVisible-Tracks(i).LastVisible)/Tracks(i).Age;
                    obj.Results(i).Speed=norm(InstantVelocityVector);
                    %obj.Results(i).XSpeed=cos(obj.Results(i).Direction)*obj.Results(i).Speed;
                    %obj.Results(i).YSpeed=cos(obj.Results(i).Direction)*obj.Results(i).Speed;
                    obj.Results(i).Template=Tracks(i).Template;
                    obj.Results(i).Visibility=Tracks(i).Visibility;
                    
              
            end
        end
        
        function obj=Present(obj,DHM_Handles,FrameNumber)   
            ImageIn=DHM_Handles.Image;
            % Present Reconstruction
            if(obj.DataConfig.PresentReconstruction==1 && ~isempty(DHM_Handles.ReconstructedCenterIntensityZ) && ~isempty(obj.Results))
                CenterLayer=round(size(DHM_Handles.ReconstructedCenterIntensityZ,1)/2);
                LastObjectID=length(obj.Results);
                if(isempty(obj.DataConfig.Fig2))
                    obj.DataConfig.Fig2=figure(2);
                    set(obj.DataConfig.Fig2,'Resize','on');
                    ParentAxes = uipanel('Parent',obj.DataConfig.Fig2,'BorderType','none'); 
                    ParentAxes.Title = 'Intensity Reconstruction Plots'; 
                    ParentAxes.TitlePosition = 'centertop'; 
                    ParentAxes.FontSize = 12;
                    ParentAxes.FontWeight = 'bold';
                elseif(~isvalid(obj.DataConfig.Fig2))
                    obj.DataConfig.Fig2=figure(2);
                    set(obj.DataConfig.Fig2,'Resize','on');
                    ParentAxes = uipanel('Parent',obj.DataConfig.Fig2,'BorderType','none'); 
                    ParentAxes.Title = 'Intensity Reconstruction Plots'; 
                    ParentAxes.TitlePosition = 'centertop'; 
                    ParentAxes.FontSize = 12;
                    ParentAxes.FontWeight = 'bold';
                end
                ParentAxes = uipanel('Parent',obj.DataConfig.Fig2,'BorderType','none'); 
                subAxis1=subplot(2,1,1,'Parent',ParentAxes);
                if(strcmp(DHM_Handles.ReconstructConfig.Method,'1D'))
                    mesh(subAxis1,DHM_Handles.ReconstructedCenterIntensityZ);
                else
                    mesh(subAxis1,reshape(DHM_Handles.ReconstructedCenterIntensityZ(CenterLayer,:,:),size(DHM_Handles.ReconstructedCenterIntensityZ,1),[]));
                end
                view(subAxis1,[0 90]);
                ylabel(subAxis1,'Template Profile / Pixel')
                title(subAxis1,['2D intensity distribution in yz plane, Tracking ID:',num2str(obj.Results(LastObjectID).Id)])
                subAxis2=subplot(2,1,2,'Parent',ParentAxes);
                if(strcmp(DHM_Handles.ReconstructConfig.Method,'1D'))
                    CenterIntensity=DHM_Handles.ReconstructedCenterIntensityZ(CenterLayer,:);
                else
                    CenterIntensity=reshape(DHM_Handles.ReconstructedCenterIntensityZ(CenterLayer,CenterLayer,:),size(DHM_Handles.ReconstructedCenterIntensityZ,3),[]);
                end
                CenterIntensity=(CenterIntensity-min(CenterIntensity(:)))/(max(CenterIntensity(:))-min(CenterIntensity(:)));
                plot(subAxis2,CenterIntensity);
                xlabel(subAxis2,'Axial (z) Distances / steps')
                ylabel(subAxis2,'Normalized Intensity')
                legend(subAxis2,['Reconstructed Axial Distances: ' num2str(obj.Results(LastObjectID).ZPos*10^6) 'micro-meter']);
                title(subAxis2,['Intensity profile along z axis, (x=',num2str(DHM_Handles.TrackingConfig.FixedTemplateSize),',y=',num2str(DHM_Handles.TrackingConfig.FixedTemplateSize),')']);
%                 subAxis3=subplot(3,1,3,'Parent',ParentAxes);
%                 plot(subAxis3,FrameNumber,obj.Results(LastObjectID).ZPos*10^6,'.b');
%                 xlabel(subAxis3,'Frame number')
%                 ylabel(subAxis3,'Distance / micro-meter')
%                 title (subAxis3,'Reconstructed Axial Distances (micro-meter) vs Time')
%                 hold on;
                try
                    drawnow;
                catch
                   pause(.05) % Forces graphics refresh 
                end
            else
                try
                    drawnow;
                catch
                   pause(.05) % Forces graphics refresh 
                end
            end

            % Present Tracking
            if(obj.DataConfig.WriteFrame==0 && obj.DataConfig.PresentTrack==0)
               return 
            end
            
            if(~ismatrix(ImageIn))
                obj.RGB=ImageIn;
            else
                obj.RGB=repmat(ImageIn,[1 1 3]);
            end
            for i=1:length(obj.Results)
                if(~isempty(obj.Results(i).Id))
                 PARA_cir(i,:)=cat(2,obj.Results(i).Centroid(1),obj.Results(i).Centroid(2),1);
                 PARA_cir2(i,:)=cat(2,obj.Results(i).Centroid(1),obj.Results(i).Centroid(2),obj.DataConfig.Tracking.FixedTemplateSize);
                 labels_name{i}= ['ID:' num2str(obj.Results(i).Id) ', Depth:' num2str(obj.Results(i).ZPos*1000000,'%10.1f') ', Speed' num2str(obj.Results(i).Speed,'%10.1f') ', Visibility:' num2str(obj.Results(i).Visibility*100,'%10.1f')];
                end
            end
            
            % Tracking object ID
            if(~isempty(obj.Results))
                if(~isempty(obj.Results(i).Id))
                obj.RGB = insertObjectAnnotation(obj.RGB, 'circle', ...
                PARA_cir, labels_name,'Color','green');
                obj.RGB = insertShape(obj.RGB, 'circle', ...
                PARA_cir2,'Color','blue');
                end
            end
            % Tracking Border
            if(strcmp(DHM_Handles.TrackingConfig.NN.TrackingROI,'On'))
                obj.RGB = insertObjectAnnotation(obj.RGB, 'rectangle', ...
                    [obj.DataConfig.Tracking.FixedTemplateSize+1 obj.DataConfig.Tracking.FixedTemplateSize+1 ...
                    size(ImageIn,2)-2*obj.DataConfig.Tracking.FixedTemplateSize size(ImageIn,1)-2*obj.DataConfig.Tracking.FixedTemplateSize], 'Tracking Area','Color','red');
            end
            
            if(obj.DataConfig.PresentTrack==1)
                if(isempty(obj.DataConfig.Fig1))
                    obj.DataConfig.Fig1=figure(1);
                    set(obj.DataConfig.Fig1,'Resize','on');
                elseif(~isvalid(obj.DataConfig.Fig1))
                    obj.DataConfig.Fig1=figure(1);
                    set(obj.DataConfig.Fig1,'Resize','on');
                end
                allAxesInFigure = findall(obj.DataConfig.Fig1,'type','axes');
                if(isempty(allAxesInFigure))
                    imshow(obj.RGB);
                    title(['Frame:',num2str(FrameNumber)]);
                else
                    imshow(obj.RGB,'Parent', allAxesInFigure(1));
                    title(allAxesInFigure(1),['Frame:',num2str(FrameNumber)]);
                end
                
                try
                    drawnow;
                catch
                   pause(.05) % Forces graphics refresh 
                end
            else
                try
                    drawnow;
                catch
                   pause(.05) % Forces graphics refresh 
                end
            end

        end
        
        function obj=SaveData(obj,Sets,FrameIndex,Detection)
            if(obj.DataConfig.WriteFrame==1)
                 track_name_image=strcat('frame_',num2str(FrameIndex,'%05.0f'));
                 name_detected=strcat(obj.DataConfig.PathDetection, track_name_image,'.png');
                 imwrite(obj.RGB,name_detected,'png');
            end
                
                DataSaveOperator=CLASS_DATAIO_IMPLEMENTATION;
                finalArr = [];
                 for i=1:length(obj.Results)
                     
                   %% Save Tracks
                     Track_name= obj.Results(i).Id;
                     SaveTracksPath=strcat(obj.DataConfig.PathTracking,'Track',num2str(Track_name));
                     DataSaveOperator.SetAddr(SaveTracksPath);
                     % Specify data to write 
                     n = length(Detection);
                     l = length(obj.Results);
                     
                     if n<l
                     DataSaveOperator.SaveData([FrameIndex obj.Results(i).Centroid*obj.Results(i).ConversionFactor obj.Results(i).ZPos 0 0]);
                       
                     elseif ~isempty(Detection(i).MajorAxisLength) && ~isempty(Detection(i).MinorAxisLength) && ~isnan(Detection(i).MajorAxisLength) && ~isnan(Detection(i).MinorAxisLength) 
                     DataSaveOperator.SaveData([FrameIndex obj.Results(i).Centroid*obj.Results(i).ConversionFactor obj.Results(i).ZPos Detection(i).MajorAxisLength Detection(i).MinorAxisLength ]);
                     
                     else
                     DataSaveOperator.SaveData([FrameIndex obj.Results(i).Centroid*obj.Results(i).ConversionFactor obj.Results(i).ZPos 0 0]);    
                    %
                     end
                     %FXYZMM = [FrameIndex obj.Results(i).Centroid*obj.Results(i).ConversionFactor obj.Results(i).ZPos Detection(i).MajorAxisLength Detection(i).MinorAxisLength];
                     %finalArr = [finalArr; FXYZMM];
                     
                 end
        end
        
        function obj=ResetPlayer(obj)
            if(~isempty(obj.DataConfig.Fig1))
                if(isvalid(obj.DataConfig.Fig1))
                    close(obj.DataConfig.Fig1)
                end
            end
            if(~isempty(obj.DataConfig.Fig2))
                 if(isvalid(obj.DataConfig.Fig2))
                    close(obj.DataConfig.Fig2)
                end
            end
        end
    end
end