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
classdef CLASS_DATAIO_IMPLEMENTATION < CLASS_DATAIO_INTERFACE
   
    methods       
        function obj=GetAddr(obj,varargin)
            if(nargin<2)
                pathname = uigetdir('','Select a path');
            else
                pathname=varargin{1};
            end
            if  isempty(pathname)
                error('User pressed cancel');
            else
                disp(['User selected ', pathname]);
            end            
            obj.Address = struct('address',[],'type',[]);
            all_files=dir(pathname);
            data_id=1;
            for id = 1:length(all_files)
                [~, ~, format_ext] = fileparts(all_files(id).name);
                switch lower(format_ext)
                    case '.txt'
                        obj.Address(data_id).address = fullfile(pathname , all_files(id).name);
                        obj.Address(data_id).name = all_files(id).name;
                        obj.Address(data_id).type = 'TXT';
                        data_id=data_id+1;
                    otherwise
                end
            end   
        end
        
       function obj=GetData(obj)
           if  isempty(obj.Address)
              error('CLASS_DATAIO_IMPLEMENTATION: no address available...') 
           end
           
           for i=1:length(obj.Address)
               obj.Data{i}=importdata(obj.Address(i).address);
           end
                
       end
       
       function obj=SetAddr(obj,Address)
           obj.SavingAddress=Address;
       end
       
       function obj=SaveData(obj,Data)
           if(isempty(obj.SavingAddress))
               mkdir('SavedData');
               filename=strcat('SavedData/','AutoSave.txt');
               %filename_xls=strcat('SavedData/','AutoSave.xls');
           else
               filename=strcat(obj.SavingAddress,'.txt');
               %filename_xls=strcat(obj.SavingAddress,'.xls');
           end
          if exist(filename, 'file') == 2
               dlmwrite(filename,Data,'delimiter',' ','-append');
           else
               dlmwrite(filename,Data,'delimiter',' ');
          end
       end
    end
    
end