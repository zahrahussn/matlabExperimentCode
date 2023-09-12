
load images;

tmpface=images.andrea;
filter1=bpfilter(2,20,256);
filter2=bpfilter(4,20,256);
filter3=bpfilter(8,20,256);

tmpface01=bpimage(tmpface,filter1,1);

figure(4); figure(5); figure(6);

tmpface02=bpimage(tmpface,filter2,1);

figure(7); figure(8); figure(9);

tmpface03=bpimage(tmpface,filter3,1);
