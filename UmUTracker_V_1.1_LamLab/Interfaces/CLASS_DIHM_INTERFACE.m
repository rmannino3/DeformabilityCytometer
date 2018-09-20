classdef CLASS_DIHM_INTERFACE < handle
    
    properties
        ReconstructConfig=[]; 
    end
    properties (SetAccess = public, GetAccess = public)
        ReconstructedCenterIntensityZ=[];
        ZPos=[];
    end
    
    methods (Abstract)
        %Reconstruct(obj);
        GetZ(obj);
    end
end