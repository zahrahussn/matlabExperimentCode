function bitsNumbers = pbExtractBITSnumbers(calrecord,fitted)

    if nargin<1
        error('you must pass a calibration record to this function');
    end;
    if nargin<2
        fitted=0;
    end;
%     if (isfield(calrecord,'calType')==1)&(strcmp(calrecord.calType,'BITS')==1)
    if pbisBITScalrecord(calrecord)==0
        error('this is not a BITS-type calibration record');
    end;
    if(fitted==0)
        bitsNumbers = calrecord.caldata(:,8);
    else
        bitsNumbers = calrecord.calmatrix(:,end);
    end;
