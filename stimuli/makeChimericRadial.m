
stim=makeRadialStim([2,3,4,5],[10,4,3,3],[0,0,30,180]);
stim=flipud(stim);

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

imshow(Scale([leftchim,stim, rightchim]));
%pause(5)
% 
%  imwrite(Scale(tmpface),['O', num2str(i),'.jpeg'],'JPEG');
%  imwrite(Scale(Mface),['M', num2str(i), '.jpeg'],'JPEG');
%  imwrite(Scale(leftchim),['LL', num2str(i), '.jpeg'],'JPEG');
%  imwrite(Scale(rightchim),['RR', num2str(i),'.jpeg'],'JPEG');
%end



    
