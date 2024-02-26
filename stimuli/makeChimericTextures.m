
load noiseStruct6-8_asym70.mat;

 adj=0;
% rot=0;
% mid=0;
% i=57;
for i = 1:20
tmpstim=images.(['nz',num2str(i)]);
Mface=fliplr(tmpstim);
%tmpface=imrotate(tmpface, rot, 'bilinear', 'crop');
tmpl=tmpstim(:, 1:(256/2)+adj);
tmpr=tmpstim(:, ((256/2)+1)+adj: 256);

leftchim=[tmpl fliplr(tmpl)];
rightchim=[fliplr(tmpr) tmpr];

imshow(Scale([leftchim,tmpstim, rightchim]));
pause(1)

 imwrite(Scale(tmpstim),['tex68_70', num2str(i),'.jpeg'],'JPEG');
 imwrite(Scale(Mface),['tex68_70_m', num2str(i), '.jpeg'],'JPEG');
 imwrite(Scale(leftchim),['tex68_70_LL', num2str(i), '.jpeg'],'JPEG');
 imwrite(Scale(rightchim),['tex68_70_RR', num2str(i),'.jpeg'],'JPEG');
end



    
