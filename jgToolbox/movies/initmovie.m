function reel = initmovie( destID, nframes, framesize, bits )% INITMOVIE  Initialize a movie reel%% reel = initmovie( destID, nframes, framesize, bits )%     - <destID> is ID of window in which movie is to be played%     - <nframes> is number of frames in movie%     - <framesize> is size of movie frame matrix, i.e. [ X Y ]%     - <reel> is structure containing information related to movie,%       but need not be altered by user%     - <bits> is bit depth of screen (default=8)%% example:  play a movie of white noise%%     for f=1:25,%          imageMat(:,:,f) = random('unif',0,255,256,256);%     end%%     winID = screen(0,'OpenWindow',0);%     mvReel = initmovie( winID, 5, [ 256 256 ] );%     filmmovie( mvReel, imageMat );%     playmovie( mvReel, 5, 20 );%     screen('CloseAll');%% See also FILMMOVIE, PLAYMOVIE, FREEMOVIE.% 30-Oct-97 -- created (RFM)% set default argumentsdefarg('bits',8);% record parametersreel.destID = destID;reel.nframes = nframes;reel.framesize = framesize;reel.view = [ 0 0 framesize(1) framesize(2) ];reel.bitdepth = bits;% calculate centered viewing window to use as defaultdestRect = screen(reel.destID,'Rect');deltaView = round( [ destRect(1) + destRect(3) - framesize(1), ...	                 destRect(2) + destRect(4) - framesize(2) ]/2 );reel.destView = reel.view + [ deltaView deltaView ];% allocate offscreen windowsfor f=1:reel.nframes,	reel.frameID(f) = screen(reel.destID,'OpenOffscreenWindow',0,reel.view,reel.bitdepth);endreturn