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
classdef CLASS_GETVI_IMPLEMENTATION_GetVideo_Vision < CLASS_GETVI_INTERFACE_GetVideo
    % Set the address for different kinds of files
    properties (SetAccess = protected, GetAccess = public)
        VideoSrc='';
        TotalFrames=0;
        FrameRate=0;
        BitsPerPixel='';
        Width=0;
        Height =0;
        ColorFormat='';
    end
    
    methods
        %% Implementation
        function  obj=GetVideo(obj,address)
            if nargin > 1
                if(ischar(address))
                    try
                        % Only for .avi .mj2 .ogg .ogv
                        obj.VideoSrc=VideoReader(address);
                        obj.TotalFrames=round(obj.VideoSrc.Duration*obj.VideoSrc.FrameRate);
                        obj.Im=readFrame(obj.VideoSrc);
                        obj.FrameNumber=round(obj.VideoSrc.CurrentTime*obj.VideoSrc.FrameRate);
                        obj.FrameRate = obj.VideoSrc.FrameRate;
                        obj.BitsPerPixel = obj.VideoSrc.BitsPerPixel;
                        obj.Width  = obj.VideoSrc.Width;
                        obj.Height = obj.VideoSrc.Height;
                        obj.ColorFormat=  obj.VideoSrc.VideoFormat;
                        %
                        obj.Readable=1;
                    catch
                        disp('Cannot find/read the video, invalid address/file...');
                        return
                    end
                else
                    disp('The format of address is not a string...')
                end
            else
                disp('Video address not assigned...')
            end
        end
        
    end
    
end