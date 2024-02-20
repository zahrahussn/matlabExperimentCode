
% leaves
% stim=makeRadialStim([3,5,10],[10,10,5],[0,20,0]); %leaf
% stim=flipud(stim);

% butterflies
stim=makeRadialStim([2,3,4,5,10],[10,30,20,5,7],[180,180+10,180+10,10,180]);
stim=flipud(stim);

% heads
% i = -40; % A3
% j = 200; % A4
% k = 0; % A5
% phiRot = 18;
% stim=makeRadialStim([1 2 3 4 5 6 7],[7 20 5*(100+i)/100 1*(100+j)/100  0.4*(100+k)/100  0.5 0.3],...
%                     [0 0 180+phiRot 0+phiRot 180-0.15*phiRot 180 180]);
% stim=flipud(stim);

adj=0;
rot=0;
mid=0;
i=57;
%for i = 1:86
mirrorstim=fliplr(stim);
%tmpface=imrotate(tmpface, rot, 'bilinear', 'crop');
tmpl=stim(:, 1:(256/2)+adj);
tmpr=stim(:, ((256/2)+1)+adj: 256);

leftchim=[tmpl fliplr(tmpl)];
rightchim=[fliplr(tmpr) tmpr];

imshow(Scale([rightchim,stim, leftchim]));
%pause(5)
% 
%  imwrite(Scale(tmpface),['O', num2str(i),'.jpeg'],'JPEG');
%  imwrite(Scale(Mface),['M', num2str(i), '.jpeg'],'JPEG');
%  imwrite(Scale(leftchim),['LL', num2str(i), '.jpeg'],'JPEG');
%  imwrite(Scale(rightchim),['RR', num2str(i),'.jpeg'],'JPEG');
%end



    
