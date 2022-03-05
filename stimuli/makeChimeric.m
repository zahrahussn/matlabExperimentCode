
load faces2020;

adj=-1;
rot=0;
mid=0;
i=57;
%for i = 1:86
tmpface=faces2020.(['stim',num2str(i)]);
Mface=fliplr(tmpface);
%tmpface=imrotate(tmpface, rot, 'bilinear', 'crop');
tmpl=tmpface(:, 1:(256/2)+adj);
tmpr=tmpface(:, ((256/2)+1)+adj: 256);

leftchim=[tmpl fliplr(tmpl)];
rightchim=[fliplr(tmpr) tmpr];

imshow(Scale([leftchim,tmpface, rightchim]));
%pause(5)
% 
%  imwrite(Scale(tmpface),['O', num2str(i),'.jpeg'],'JPEG');
%  imwrite(Scale(Mface),['M', num2str(i), '.jpeg'],'JPEG');
%  imwrite(Scale(leftchim),['LL', num2str(i), '.jpeg'],'JPEG');
%  imwrite(Scale(rightchim),['RR', num2str(i),'.jpeg'],'JPEG');
%end



    
