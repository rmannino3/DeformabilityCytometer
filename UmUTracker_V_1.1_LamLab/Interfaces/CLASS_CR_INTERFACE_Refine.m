classdef CLASS_CR_INTERFACE_Refine < handle
    
    properties
        % Inputs
        RefinementConfig=[];
    end
    
    properties (SetAccess = protected, GetAccess = public)
        % Outputs
        DiffractionPattern=[];
        DiffractionPattern1D=[];
        PatternCenter=[];
        Shift=[0 0];
    end
    
    methods (Abstract)
        Refine(obj);
    end
end