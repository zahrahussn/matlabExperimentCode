function [ ] = InitSDS( StimA, StimB, StimLevels )% InitSDS - create stimulus files needed for SDS simulations%%      [ ] = InitSDS( StimA, StimB, StimLevels )% load vision constantsglobal PupilArea OptTrans PSF RAF SCSigmaload visnums% check for initialization flagFlagName = [ StimA '_' StimB '.mat' ];if exist(FlagName)==2,	returnend% create files containing all required photoreceptor-mosaic imagesfor StimLet='A':'B',	StimName = eval(['Stim' StimLet ]);	Unc = feval([ StimName 'Prob' ],-1);	for i=1:size(StimLevels,2),		StimLevel=StimLevels(i);   % look up stimulus level		UncX = ones(size(Unc));    % init uncertainty vector		while 1,			% construct external stimulus			Stim=feval( [ StimName 'Img' ] ,StimLevel,UncX);			% determine photoreceptor-mosaic image			Photo = PhotoImg(RetImg(Stim));			% determine template and image volume			Template = log(Photo);			Volume = sum(sum(Photo));			% save required information			FName = StimFName(StimName,StimLevel,UncX);			eval(['save ' FName ' Photo Template Volume']);			fprintf(1,'%s\n',FName);			% advance to next uncertainty vector			[ UncX Wrap ] = NextUnc(UncX,Unc);			if Wrap==1,				break			end		end	endend% leave initialization flag in directoryeval([ 'save ' FlagName ' StimA StimB StimLevels' ]);return