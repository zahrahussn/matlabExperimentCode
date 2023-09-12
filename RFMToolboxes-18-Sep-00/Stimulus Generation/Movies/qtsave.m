function qtsave( img, fname, fps )% QTSAVE  Save an image deck as a QuickTime movie%% qtsave( img, fname, fps )% 24-Jul-99 -- created (RFM)defarg('fname',[ inputname(1) '.qt' ]);defarg('fps',10);map=(0:255)'*ones(1,3)/255;qtwrite(qtscale(img),size(img),map,fname,[ fps 3 3 ]);return