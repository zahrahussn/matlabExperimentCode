function newCalRec=pbCorrectCalibration(rawCalRec,errorRec)

    Lum = rawCalRec.caldata(:,5);

    Y = errorRec.theError;
    X = errorRec.rgbNumber;
    xi=1:length(Lum);
    yi=interp1(X,Y,xi,'pchip');

    newCalRec=rawCalRec;
    newCalRec.caldata(:,5)= rawCalRec.caldata(:,5)+yi';
    
    tmpLum=newCalRec.caldata(:,5);
    [LumSorted,ti]=sort(tmpLum);
    

    newCalRec.caldata=newCalRec.caldata(ti,:);
    
    

    LumValues = pbExtractLuminanceValues(newCalRec);
    rgbNumbers = pbExtractNumbers(newCalRec);
    bkgrndNumber = newCalRec.backgroundNumber;
    newCalRec.lmaxminave=pbLookupScalar([pbMaxBITStealingIndex,1,bkgrndNumber],LumValues,rgbNumbers);




