function b=pbisBITScalrecord(calrecord)

    if (isfield(calrecord,'calType')==1)&(strcmp(calrecord.calType,'BITS')==1)
        b=1;
    else
        b=0;
    end;
    