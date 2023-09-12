function [displayWidth,displayHeight] = pbGetScreenDimensions(whichScreen)
% function [displayWidth,displayHeight] = pbGetScreenDimensions(curWidth,curHeight)

    if nargin<1
        whichScreen = max(Screen('Screens'));
    end;
    [widthmm, heightmm]=Screen('DisplaySize', whichScreen);
    displayWidth=widthmm/10;
    displayHeight=heightmm/10;
    
%     if exist('curWidth','var')==0
%         displayWidth = NaN;
%     else
%         displayWidth = curWidth;
%     end;
%     
%     if exist('curHeight','var')==0
%         displayHeight = NaN;
%     else
%         displayHeight = curHeight;
%     end;
%     
    
    
    

    WaitSecs(0.5); % wait a moment...
%     fprintf('\n>>> Make sure the display is set to the correct spatial resolution...\n')
%     fprintf('(calibration)$ hit any key to continue...\n');
%     WaitSecs(0.1);
%     while(KbCheck==0)
%     end;
    
    

    theInput=input(sprintf('>>> Enter the display WIDTH or hit return (%g) : ',displayWidth),'s');

    if isempty(theInput)==0 && isempty(str2num(theInput))==0
        displayWidth=abs(str2num(theInput));
    end;
            
    theInput=input(sprintf('>>> Enter the display HEIGHT or hit return (%g) : ',displayHeight),'s');

    if isempty(theInput)==0 && isempty(str2num(theInput))==0
        displayHeight=abs(str2num(theInput));
    end;
    
