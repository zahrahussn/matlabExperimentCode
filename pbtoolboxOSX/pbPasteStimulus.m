function oldarray=pbPasteStimulus(stim,x,y,oldarray)

patsize=size(stim); % rows (height), columns (width)
stimRect=[0,0,patsize(2)-1,patsize(1)-1]; % (left,top,right,bottom)
destRect=CenterRectOnPoint(stimRect,x+1,y+1);
% T=destRect(2);
% B=destRect(4);
% L=destRect(1);
% R=destRect(3);
% oldarray(T:B,L:R)=oldarray(T:B,L:R)+stim;
oldarray(destRect(2):destRect(4),destRect(1):destRect(3))=oldarray(destRect(2):destRect(4),destRect(1):destRect(3))+stim;
% newarray=oldarray;

return