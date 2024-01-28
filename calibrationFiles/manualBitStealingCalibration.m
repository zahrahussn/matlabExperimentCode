function manualBitStealingCalibration(calRec, rgbTable, lumData)

% Creates bitStealing calbiration table from manual luminance measurements
% of the R, G and B guns
%
%   inputs: calRec: structure containing information about the calibration procedure
%           rgbTable: N*4 table containing RGB values for R, G and B gun
%                    measurements + 4th column indicating if background was on
%                    (should include [0,0,0, 0] (DCoffset luminance) and [0,0,0,1] (background luminance)
%                    + we assume that guns are always measured independently)
%           lumData: luminance values measured for each row of rgbTable
%            

getDCoffset = false;
docheck = false;

% check thtat guns were measured independently
if any(sum(logical(rgbTable(:,1:3)),2)>1)
    fprintf('(ERROR) Guns were not measured independently. Exiting\n');
    return
end
% Extract luminance measurement for RGB = [0,0,0] with background off
dcOffsetIndex = find(all(~rgbTable,2));
if dcOffsetIndex
    dcOffset = lumData(dcOffsetIndex);
    if ~getDCoffset
      fprintf('(WARNING) Ignoring DC offset measurement, assuming 0\n');
      dcOffset=0;
    end
else
    fprintf('(WARNING) No luminance value for DC offset, assuming 0\n');
    dcOffset = 0;
end
% Extract luminance measurement for RGB = [0,0,0] with background on
bkgrndOffsetIndex = find(all(~rgbTable(:,1:3),2)&rgbTable(:,4));
if bkgrndOffsetIndex
    bkgrndOffset = lumData(bkgrndOffsetIndex);
else
    fprintf('(WARNING) No luminance vaue for background offset, assuming 0\n');
    bkgrndOffset = 0;
end

% Extract R, G and B luminance data (assumes guns have been measured independently and background was on)
redIndices = find(rgbTable(:,1));
Nred = rgbTable(redIndices,1);
redData = lumData(redIndices);
greenIndices = find(rgbTable(:,2));
Ngreen = rgbTable(greenIndices,2);
greenData = lumData(greenIndices);
blueIndices = find(rgbTable(:,3));
Nblue = rgbTable(blueIndices,3);
blueData = lumData(blueIndices);


%----------- Code taken from pbCalibrateBitStealing with minor changes

% convert data to Luminance
redLum=(redData-dcOffset-bkgrndOffset)';
redLum=max(redLum,0); % get rid of negative values
% insert zero:
redLum=[0;redLum];
redLUT=[0;Nred];
% do the same for the green data:
greenLum=(greenData-dcOffset-bkgrndOffset)';
greenLum=max(greenLum,0);
greenLum=[0;greenLum];
greenLUT=[0;Ngreen];
% do the same for the blue data:
blueLum=(blueData-dcOffset-bkgrndOffset)';
blueLum=max(blueLum,0);
blueLum=[0;blueLum];
blueLUT=[0;Nblue];

% interpolate data to estimate luminance corresponding to all lut values from 0 to 255
redNumber=0:255;
redInterpolated=interp1(redLUT,redLum,redNumber,'pchip');
greenNumber=0:255;
greenInterpolated=interp1(greenLUT,greenLum,greenNumber,'pchip');
blueNumber=0:255;
blueInterpolated=interp1(blueLUT,blueLum,blueNumber,'pchip');



rgbvalues=pbBitStealingArray; % create default bitstealing rgb values
n=size(rgbvalues,1);
Ltotal=zeros(n,1);

fprintf('>>> building bit-stealing lookup table...\n')
for kk=1:n
    ri=rgbvalues(kk,1);
    gi=rgbvalues(kk,2);
    bi=rgbvalues(kk,3);
    rL=interp1(redNumber,redInterpolated,ri);
    gL=interp1(greenNumber,greenInterpolated,gi);
    bL=interp1(blueNumber,blueInterpolated,bi);
    Ltotal(kk)=rL+gL+bL+bkgrndOffset;
end

[LumSorted,ti]=sort(Ltotal);
rgbSorted=rgbvalues(ti,:);
n=size(rgbSorted,1);
rgbNumbers=[1:n]';
calData=[rgbSorted,rgbNumbers,LumSorted];


bkgrndRGBnumber = pbRGB2Index(calRec.backgroundRGB,rgbSorted);
calRec.backgroundNumber = bkgrndRGBnumber;
calRec.caldata=calData;
calRec.lmaxminave=pbLookupScalar([pbMaxBITStealingIndex,1,bkgrndRGBnumber],LumSorted,rgbNumbers);

fprintf('(calibration)$ saving raw uncorrected calibration file in curCalRecTmpFileRAW.mat\n');
save(sprintf('curCalRecTmpFileRAW_%s',date), 'calRec');

save(sprintf('lumData_%s',strrep(datestr(now),':','-')),'lumData')

% haven't debugged this part
if docheck==1 
    setup.whichScreen=whichScreen;
    setup.portNumber=portNumber;
    setup.reps=reps;
    rn=round([1,[0.1:0.05:1].*size(calRec.caldata,1)] );
    fprintf('>>> measuring calibration errors...\n');
    errRec=pbCheckCalibration(calRec,rn,setup);
    fprintf('(calibration)$ adjusting lookup table...\n');
    calRec=pbCorrectCalibration(calRec,errRec);
    fprintf('(calibration)$ saving >>ADJUSTED<< calibration file in curCalRecTmpFileADJUSTED.mat\n');
    save 'curCalRecTmpFileADJUSTED' calRec;
    fprintf('>>> measuring errors in adjusted calibration...\n');
    errRec2=pbCheckCalibration(calRec,rn,setup);
end
