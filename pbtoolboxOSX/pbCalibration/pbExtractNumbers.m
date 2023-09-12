function theNumbers = pbExtractNumbers(calrecord)

    if nargin<1
        error('you must pass a calibration record to this function');
    end;
    theNumbers = calrecord.caldata(:,4);


% function theNumbers = pbExtractNumbers(calrecord,fitted)
% 
%     if nargin<1
%         error('you must pass a calibration record to this function');
%     end;
%     if nargin<2
%         fitted=0;
%     end;
%     if(fitted==0)
%         theNumbers = calrecord.caldata(:,8);
%     else
%         theNumbers = calrecord.calmatrix(:,end);
%     end;
