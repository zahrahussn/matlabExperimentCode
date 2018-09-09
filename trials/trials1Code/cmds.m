%oldEnableFlag=Screen('Preference', 'EmulateOldPTB', 1);
AssertOpenGL;
Screen('Preference', 'SkipSyncTests', 1);
numBuffers=2;
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSuppressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
[w wrect]=Screen('OpenWindow',0, 0,[],32,numBuffers);
center = [wrect(3) wrect(4)]/2;    
TxtSize=32;
TxtSizeDiv2=round(TxtSize/2);
spaceBar=44; 
Screen('TextFont',w, 'Helvet ica');
Screen('TextSize',w, TxtSize);
Screen('TextStyle', w, 0);
time0=GetSecs;
timeTxt=time0+1;
while(time0<timeTxt) 
Screen('FillRect',w, [160 160 160]);
Screen('DrawText', w, 'whatev',800,      600, 0)
[time0]=Screen('Flip', w);
end
adaptpause(w, wrect, 10,spaceBar);
Screen('glPoint', w, 0, round( center(1)), round( center(2)), 8);
Screen('Flip', w); 
theKey=pbGetKey(spaceBar,3);
load images;
load calfitrec;
L=calfitrec.caldata(:,5);
B=calfitrec.caldata(:,4);
rgbMat=calfitrec.caldata(:,1:3);   
tmpface=images.andrea;
tmpface=tmpface.*1/sqrt(var(tmpface(:)));
tmpface=tmpface.*sqrt(.002);
tmpnoise=noise2d(256,.1,-1,1);
tmpface=tmpface+tmpnoise; 
tmpfaceLum=65*(1+tmpface);
tmpfaceBS=pbLum2BS(tmpfaceLum,L,B); 
tmpfaceFinal=pbBitstealing2RGB(tmpfaceBS, rgbMat,0);
dstRect=[0 0 256 256];
dstRect=CenterRect(dstRect, wrect); 
srcRect=[0 0 256 256];
Stim=Screen('MakeTexture', w, tmpfaceFinal);  
time0=GetSecs;
timeStim=time0+1;
while(time0<timeStim)
Screen('DrawTexture', w, Stim, srcRect, dstRect  );
[time0]= Screen('Flip', w);
end
theKey=pbGetKey(spaceBar,3);
 close all  
 sca       
  
 