function rgbMatrix = pbExtractRGB(calrecord)

    if nargin<1
        error('you must pass a calibration record to this function');
    end;

    rgbMatrix = calrecord.caldata(:,1:3);
    

