classdef CLASS2_LOADVI_INTERFACE_LoadVideo < handle
    % Set the address for different kinds of files
    
    methods (Abstract)  
        LoadVideo(obj)
        GetFrame(obj)
        Reset(obj)
    end
    
end