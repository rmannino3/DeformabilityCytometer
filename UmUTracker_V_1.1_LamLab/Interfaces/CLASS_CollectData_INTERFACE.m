classdef CLASS_CollectData_INTERFACE < handle 
    properties
       % inputs
        DataConfig={}; 
    end
    properties (SetAccess = protected, GetAccess = public)
        % plot handles
        ShowFrame={};
        DrawCirclesBLUE={};
        DrawCirclesRED={};
        % outputs
        RGB={};
        Results={};
    end
    
    methods (Abstract)
        Collect(obj);
        Update(obj);
        Present(obj);
        SaveData(obj);
        ResetPlayer(obj);
    end
    
    
end