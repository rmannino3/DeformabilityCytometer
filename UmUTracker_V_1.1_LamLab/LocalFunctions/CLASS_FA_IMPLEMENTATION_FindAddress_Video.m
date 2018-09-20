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
classdef CLASS_FA_IMPLEMENTATION_FindAddress_Video < CLASS_FA_INTERFACE_SetFileAddr & CLASS_FA_INTERFACE_SetFileAddr_UI
    
    methods
        
        function video_ad_obj=SetAddress(video_ad_obj,Address)
            if nargin > 1
                    if(ischar(Address))
                        video_ad_obj.fullpath=Address;
                        [video_ad_obj.path, video_ad_obj.name,video_ad_obj.extension] = fileparts(video_ad_obj.fullpath);
                    else
                        disp('The address is not a string...')
                    end
            end
            if sum(strcmp(video_ad_obj.extension,{'.avi', '.mpg', '.mpeg', '.wmv', '.mp4',',mov','.mj2'}))>=1
                video_ad_obj.valid=1;
            end
        end
        
        function video_ad_obj=SetAddressUI(video_ad_obj)
            [filename, pathname] = uigetfile( ...
                {'*.avi;*.mpg;*.mpeg;*.wmv;*.mp4;*.mj2;*.mov','Video Files (*.avi,*.mpg,*.mpeg,*.wmv,*.mp4,*.mj2,*.mov)';
                '*.*',  'All Files (*.*)'}, ...
                'Select a video file');
            if(sum(pathname==0) || sum(filename==0))
                disp('Cancelled...');
                return
            else
                video_ad_obj.fullpath=[pathname filename];
                [video_ad_obj.path, video_ad_obj.name,video_ad_obj.extension] = fileparts(video_ad_obj.fullpath);
                video_ad_obj.valid=1;
            end
        end
    end
    
end