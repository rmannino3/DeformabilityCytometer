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
classdef CLASS2_LOADVI_IMPLEMENTATION_LoadVideo < CLASS_FA_IMPLEMENTATION_FindAddress_Video & CLASS_GETVI_IMPLEMENTATION_GetVideo_Vision & CLASS2_LOADVI_INTERFACE_LoadVideo
    % Set the address for different kinds of files  
    methods
        
        function obj=LoadVideo(obj,Address)
            if nargin>1
                %% subclass methods implementations
                addr_inst=CLASS_FA_IMPLEMENTATION_FindAddress_Video;
                getvideo_inst=CLASS_GETVI_IMPLEMENTATION_GetVideo_Vision;
                %% operations
                % setp 1
                addr_inst.SetAddress(Address);
                % setp 2
                getvideo_inst.GetVideo(addr_inst.fullpath);
                % Copy properties to object
                proplist_addr = properties(addr_inst);
                for i=1:length(proplist_addr)
                    obj.(proplist_addr{i}) =addr_inst.(proplist_addr{i});
                end 
                proplist_video = properties(getvideo_inst);
                for i=1:length(proplist_video)
                    obj.(proplist_video{i}) = getvideo_inst.(proplist_video{i});
                end 
            else
              %% subclass methods implementations
                addr_inst=CLASS_FA_IMPLEMENTATION_FindAddress_Video;
                getvideo_inst=CLASS_GETVI_IMPLEMENTATION_GetVideo_Vision; 
              %% operations
                % setp 1
                addr_inst.SetAddressUI();
                % setp 2
                getvideo_inst.GetVideo(addr_inst.fullpath); 
                getvideo_inst.FrameNumber=1;
                getvideo_inst.FrameRate=1/getvideo_inst.VideoSrc.CurrentTime;
                getvideo_inst.TotalFrames=round(getvideo_inst.VideoSrc.Duration./getvideo_inst.VideoSrc.CurrentTime);
                % Copy properties to object
                proplist_addr = properties(addr_inst);
                for i=1:length(proplist_addr)
                    obj.(proplist_addr{i}) =addr_inst.(proplist_addr{i});
                end
                proplist_video = properties(getvideo_inst);
                for i=1:length(proplist_video)
                    obj.(proplist_video{i}) = getvideo_inst.(proplist_video{i});
                end
            end
        end
        
        function obj=GetFrame(obj,CurrentFrameNumber)
            if(obj.Readable==1)
                if(nargin>1)
                        if(CurrentFrameNumber>=0 && CurrentFrameNumber<obj.TotalFrames)
                            set(obj.VideoSrc,'CurrentTime',CurrentFrameNumber/obj.FrameRate);
                            obj.Im=readFrame(obj.VideoSrc);
                            obj.FrameNumber=round(obj.VideoSrc.CurrentTime*obj.FrameRate); 
                        end
               
                else
                    if(obj.VideoSrc.CurrentTime<obj.VideoSrc.Duration)
                        obj.Im=readFrame(obj.VideoSrc);
                        obj.FrameNumber=obj.FrameNumber+1;
                    else
                        obj.FrameNumber=obj.FrameNumber+1;
                    end
                end
            end
        end
        
        function obj=Reset(obj)
            set(obj.VideoSrc,'CurrentTime',0);
            obj.Im=readFrame(obj.VideoSrc);
            obj.FrameNumber=round(obj.VideoSrc.CurrentTime*obj.VideoSrc.FrameRate);
        end
    end
end