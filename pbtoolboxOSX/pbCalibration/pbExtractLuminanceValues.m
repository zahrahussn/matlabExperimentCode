function lumValues = pbExtractLuminanceValues(calrecord)

    if nargin<1
        error('you must pass a calibration record to this function');
    end;

    lumValues = calrecord.caldata(:,5);
    

% function lumValues = pbExtractLuminanceValues(calrecord,fitted)
% 
%     if nargin<2
%         fitted=0;
%     end;
%     
%     if fitted==0
%         lumValues = calrecord.caldata(:,5);
%     else
%         lumValues = calrecord.calmatrix(:,4);
%     end;
%     
