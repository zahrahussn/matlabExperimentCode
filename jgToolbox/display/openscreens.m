function [mainptrs,mainrects] = openscreens(mainscrs,mainCLUTs,otherCLUTs)% function [mainptrs,mainrects] = openscreens(mainscrs,mainCLUTs,otherCLUTs)%% open all screens available. the experimental screen(s) are passed in mainscrs.% mainscrs is a vector with each element corresponding to a screen id. the% corresponding CLUTS are passed as an [N] x [3] x [The number of main screens]% matrix mainCLUTs, with each set of 3 rows the CLUT for the corresponding screen% number passed in mainscrs. any remaining screens not passed through mainscrs% are opened and set with the clut otherCLUTS. The pointers to the mainscreens% passed are returned in mainptrs, in the same order passed. The corresponding% screen rects are also returned as rows of the matrix mainrects.%% Error handling:% if openscreens alone is called (i.e.,if mainscrs is not passed)% all available screens are opened with a dummy CLUT of mid-gray (160).% if only mainscrs is passed, the main screens are opened to mid gray and% the remaining screens are set to zero.% if otherCLUTs is not passed, dummy zero cluts are used for the remaining screens.% If any of the mainCLUTs are missing, the remaining main screens are set using the% first CLUT passed in mainCLUTs. %% June 30 1998  JMG U of T Vision Lab% July 12, 1998: JMG added error handling% get the screensscreens=screen('Screens');% check to see if cluts were passedif nargin < 3	otherCLUTs = zeros(256,3);endif nargin < 2	mainCLUTs = ones(256,3)*160;end% check to see if main screen was passedif nargin < 1 | isempty(intersect(screens,mainscrs))	mainscrs = 0;	otherCLUTs = mainCLUTs;end% make sure there are no repeated screens passed[uniquescreens,uniqueindeces] = unique(mainscrs);if length(uniquescreens)~=length(mainscrs)	for i = 1:length(uniqueindeces)		mainscrstmp(i) = mainscrs(uniqueindeces(i));	end	mainscrs = mainscrstmp;end% open the screensscreencount=1;for i = 1:length(mainscrs)	if find(mainscrs(i)==screens)		[mainptrs(screencount),mainrects(screencount,:)]=screen(mainscrs(screencount),'OpenWindow',0);		if cols(mainCLUTs) >= screencount*3			screen(mainptrs(screencount),'SetClut',mainCLUTs(:,screencount*3-2:screencount*3),0);		else			screen(mainptrs(screencount),'SetClut',mainCLUTs(:,1:3),0);		end					screencount=screencount+1;	endendif length(screens)>length(intersect(mainscrs,screens))	thisscreen = screencount;	for i = 1:length(screens)		if isempty(find(screens(i)==mainscrs))			eval(['[screen',num2str(thisscreen),',temp]=screen(',num2str(screens(i)),',''OpenWindow'',1);']);			eval(['screen(screen',num2str(thisscreen),',''SetClut'',otherCLUTs,0);']);			thisscreen = thisscreen+1;		end	endendreturn