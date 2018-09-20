classdef CLASS_PostProcessing < handle
   properties (SetAccess = protected, GetAccess = public)
        PostP_FolderPath='';
        PostP_FilePaths='';
        PostP_FileType='.txt';
        PostP_Data='';
        PostP_DataSize=0;
        PostP_Collect_Data='';
        PostP_Display=[];
   end
    
    methods
       function obj=SetType(obj,Type_input)
           if isstring(Type_input)
              switch lower(Type_input)
                  case {'.txt','txt'}
                      obj.PostP_FileType='.txt';
                  case {'.xlsx','xlsx'}
                      obj.PostP_FileType='.xlsx';
                  otherwise
                      obj.PostP_Display='Set_type:Incorrect Type. Default type: .txt';
                      obj.UpdateDisplay_Console;
                      obj.PostP_FileType='txt';
              end
           else
               obj.PostP_Display='Set_type:Incorrect Type. Default type: .txt';
               obj.UpdateDisplay_Console
           end
       end
       function obj=LoadSingleFile(obj,varargin)
           [filename, pathname] = uigetfile( ...
               {'*.txt;','Configuration Files (*.txt)';
               '*.*',  'All Files (*.*)'}, ...
               'Select a configuration file');
           if(sum(pathname==0) || sum(filename==0))
               disp('Cancelled...');
               obj.PostP_DataSize=0;
               return
           else
               obj.PostP_DataSize=1;
               obj.PostP_FilePaths=strcat(pathname,filename);
           end
           switch lower(obj.PostP_FileType)
               case '.txt'
                   % Assign file name
                   obj.PostP_Data(1).name = filename;
                   % Collect data
                   obj.PostP_Data(1).data = dlmread(obj.PostP_FilePaths);
                   obj.PostP_Data(1).datalength = length(obj.PostP_Data(1).data);
               case '.xlsx'
                   % Assign file name
                   obj.PostP_Data(1).name = filename;
                   % Collect data
                   obj.PostP_Data(1).data = xlsread(obj.PostP_FilePaths);
                   obj.PostP_Data(1).datalength = length(obj.PostP_Data(1).data);
               otherwise
           end
       end
       function obj=Load(obj,varargin) 
           if(nargin>1) % Pre-defined path
               Para_Inputs = length(varargin);
               for n = 1:Para_Inputs
                   try
                       switch varargin{n};
                           case 'FolderPath'   %  FolderPath
                               n=n+1;
                               if(isstring(varargin{n}))
                                   obj.PostP_FilePaths=dir(obj.varargin{n});
                               end
                           otherwise
                       end
                       % Update Parameters
                       obj.PostP_DataSize=0;
                   catch
                        obj.PostP_Display='Load_file:Incorrect Input';    
                        obj.UpdateDisplay_Console;
                   end
               end
           else % Manually select path
               obj.import_all_manual;
           end 
           obj.PostP_Data = struct('name',[],'data',[],'datalength',0);
           inc=1;
           switch lower(obj.PostP_FileType)
               case '.txt'
                    for id = 1:length(obj.PostP_FilePaths)
                        if ~(strcmp(obj.PostP_FilePaths(id).name,'.') || strcmp(obj.PostP_FilePaths(id).name,'..'))
                        % Assign file name
                            obj.PostP_Data(inc).name = obj.PostP_FilePaths(id).name;
                        % Collect data
                        obj.PostP_Data(inc).data = dlmread(strcat(obj.PostP_FolderPath,'\',obj.PostP_Data(inc).name));
                        obj.PostP_Data(inc).datalength = size(obj.PostP_Data(inc).data,1);
                        if(obj.PostP_Data(inc).datalength>obj.PostP_DataSize)
                            obj.PostP_DataSize=obj.PostP_Data(inc).datalength;
                        end
                        inc=inc+1;
                        end
                    end
               case '.xlsx'
                    for id = 1:length(obj.PostP_FilePaths)
                        if ~(strcmp(obj.PostP_FilePaths(id).name,'.') || strcmp(obj.PostP_FilePaths(id).name,'..'))
                        obj.PostP_Data(inc).name = obj.PostP_FilePaths(id).name;
                        obj.PostP_Data(inc).data = xlsread(strcat(obj.PostP_FolderPath,'\',obj.PostP_FilePaths(id).name));
                        obj.PostP_Data(inc).datalength = size(obj.PostP_Data(inc).data,1);
                        if(obj.PostP_Data(inc).datalength>obj.PostP_DataSize)
                            obj.PostP_DataSize=obj.PostP_Data(inc).datalength;
                        end
                        inc=inc+1;
                        end
                    end
               otherwise

           end 
       end
       
       function CollectData=Collect(obj,varargin) 
           CollectData=zeros(obj.PostP_DataSize,length(varargin),length(obj.PostP_Data));
           for i=1:length(obj.PostP_Data)
               for j=1:length(varargin)
                   if(obj.PostP_Data(i).datalength>0)
                        CollectData(1:obj.PostP_Data(i).datalength,j,i)=obj.PostP_Data(i).data(:,varargin{j});
                   end
               end
           end
       end
       
       function obj=UpdateDisplay_Console(obj)
           disp(obj.PostP_Display);
       end
       
       function obj=import_all_manual(obj)
            pathname = uigetdir('','Select a path');
            if  pathname==0
                obj.PostP_Display='Cancelled...';
                obj.UpdateDisplay_Console
                obj.PostP_DataSize=0;
                return
            else
                obj.PostP_FolderPath=pathname;
                obj.PostP_FilePaths=dir(obj.PostP_FolderPath);
                obj.PostP_Display=obj.PostP_FolderPath;
                obj.UpdateDisplay_Console
                % Update Parameters
                obj.PostP_DataSize=0;
            end 
        end

    end

end