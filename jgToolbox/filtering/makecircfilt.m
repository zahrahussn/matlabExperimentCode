function images = makecircfilt(sz,n,center,mainrad,maxrad,circrad)% center = [x,y]if exist('circrad','var')	if mainrad + circrad <= center(1)		% circumference		circum = 2*pi*mainrad;		ang = round(360/n);		circle = imcircle(circrad*2);		offset = floor(sz/2);		locs = zeros(n,2);		for i = 1:n			locs(i,:) = round([mainrad*cos(deg2rad(ang*(i-1))),mainrad*sin(deg2rad(ang*(i-1)))]);  %[x,y]			tempimage = zeros(sz,floor(sz/2));			newcenter = [center(1)+locs(i,1),offset-center(2)-locs(i,2)];			tempimage(newcenter(2)-circrad+1:newcenter(2)+circrad,newcenter(1)-circrad+1:newcenter(1)+circrad) = circle;			tempimage = [fliplr(flipud(tempimage)),tempimage];			newtemp = zeros(sz);			newtemp = newtemp(2:end,2:end)+tempimage(1:end-1,1:end-1);			eval(['images.filt',num2str(i),' = tempimage;']);		end	else		printstr('The sum of the main and circle radius is to large.');		images = [];		return;		endelse	if mainrad < center(1)				if exist('maxrad','var')			if maxrad <= center(1)				rads = floor(linspace(maxrad,center(1),n));			else				rads = floor(linspace(mainrad,center(1),n));			end		else			rads = floor(linspace(mainrad,center(1),n));		end				offset = floor(sz/2);		for i = 1:n			circle = imcircle(rads(i)*2);			tempimage = zeros(sz,floor(sz/2));			tempimage(offset-center(2)-rads(i)+1:offset-center(2)+rads(i),center(1)-rads(i)+1:center(1)+rads(i)) = circle;			tempimage = [fliplr(flipud(tempimage)),tempimage];			newtemp = zeros(sz);			newtemp = newtemp(2:end,2:end)+tempimage(1:end-1,1:end-1);			eval(['images.filt',num2str(i),' = tempimage;']);		end			end	endreturn