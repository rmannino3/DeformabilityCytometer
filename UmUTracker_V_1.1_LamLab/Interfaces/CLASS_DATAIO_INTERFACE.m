classdef CLASS_DATAIO_INTERFACE < handle
    
    properties (SetAccess = protected, GetAccess = public)
        Data=[];
        Address=[];
        SavingAddress=[];
    end
    
    methods (Abstract)
        GetAddr(obj);
        GetData(obj);
        SetAddr(obj);
        SaveData(obj);
    end
end