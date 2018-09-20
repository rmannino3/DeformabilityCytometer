classdef CLASS_PREP_INTERFACE_Preprocess < handle
    properties
       PreProcessConfig=[]; 
    end
    
    properties (SetAccess = protected, GetAccess = public)
        % Output
        Image=[];
    end
    
    methods (Abstract)
        Preprocess(obj);
    end
end