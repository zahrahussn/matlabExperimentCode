function testres=pbRandCalTest(calrecord,n,stimpix,portnumber,rgbBackground,whichScreen)
%
% function testres=pbRandCalTest(calrecord,n,stimpix,portnumber,rgbBackground,whichScreen)
%
    if exist('whichScreen')==0
        whichScreen = max(Screen('Screens'));
        fprintf('testing screen %g\n',whichScreen);
    end;
    if exist('rgbBackground')==0
        rgbBackground = calrecord.background;
    end;
    
    fprintf('setting display to spatial and temporal resolution contained in calibration file...\n');
%     if (exist('calrecord.pixelsize')==1)
%         oldResolution=Screen('Resolution', whichScreen,calrecord.displaypixels(1),calrecord.displaypixels(2),calrecord.framerate,calrecord.pixelsize);
%     else
%         oldResolution=Screen('Resolution', whichScreen,calrecord.displaypixels(1),calrecord.displaypixels(2),calrecord.framerate);
%     end;
    calsize=size(calrecord.calmatrix);
    tmp=randperm(calsize(1));
    checkLum=calrecord.calmatrix(tmp(1:n),:);
    checkLum(end,:)=calrecord.calmatrix(calsize(1),:);
    
    k=200;
    while( (k>calsize(1))&(k>0))
        k=k-1;
    end;
    if(k>0)
        checkLum(end,:)=calrecord.calmatrix(k,:);
    end;
    
    checkSize=size(checkLum);
    tmp=randperm(checkSize(1));
    checkLum=checkLum(tmp,:); % randomize order
    testres=pbTestCalibration(stimpix,portnumber,checkLum(:,1:3),checkLum(:,4),rgbBackground,whichScreen);
    Screen('Resolution', whichScreen,oldResolution.width,oldResolution.height,oldResolution.hz);
  
end