classdef CLASS_GETVI_INTERFACE_GetVideo < handle
    % Set the address for different kinds of files
    properties (SetAccess = public, GetAccess = public)
        FrameNumber=0;
        Im=[];
        Readable=0;
    end
    %% Interface
    methods (Abstract)
        GetVideo(obj)
    end
    
end