classdef CLASS_BACKGROUNDSUB_INTERFACE < handle
    
   properties
       BacksubCounter=1; 
       BacksubReady=0;
       BackgroundImage=[];
       BackgroundHologram=[];
    end
    
    methods (Abstract)
        BackgroundMovingAve(obj);
        
        BackgroundSubStatic(obj);
        BackgroundHoloStatic(obj);
    end
end