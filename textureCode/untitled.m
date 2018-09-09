
load testImage;
load testImage2;


numImages=20;
Allimages2=zeros(256,256,numImages);

j=1;
for i=1:numImages
    Allimages2(:,:,j)=testImage;
    Allimages2(:,:,j+1)=testImage2;
    j=j+2;
end
   
%testfig=figure(1);
numframes=numImages;
%B=moviein(numframes,testfig);

for i = 1:numframes
    imshow(scale(Allimages2(:,:,i)));
    M(i) = getframe;
 %   B(:,i)=getframe(testfig);
end

%movie(M, 1,.5)
movie2gif(M, 'test2.gif');

%movie2avi(M, 'texRev.avi');    