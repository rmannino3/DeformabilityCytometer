classdef CLASS_FA_INTERFACE_SetFileAddr < handle
    % Set the address for different kinds of files
    properties (SetAccess = protected, GetAccess = public)
        fullpath='';
        name='';
        path='';
        extension='';
        valid=0;
    end
    
    methods
       %% Constructor
        function obj=CLASS_FA_INTERFACE_SetFileAddr(Address)
            if nargin > 0 && ~isempty(Address)
                    if(ischar(Address))
                        obj.fullpath=Address;
                        [obj.path, obj.name,obj.extension] = fileparts(obj.fullpath);
                    else
                        disp('The address is not a string...')
                    end
            end
        end
    end
    %% Interface
    methods (Abstract)
        SetAddress(obj)
    end
    
end