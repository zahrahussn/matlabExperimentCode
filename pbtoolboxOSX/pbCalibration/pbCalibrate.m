function calFitRecord=pbCalibrate()
%
% function calFitRecord=pbCalibrate()
%
    alldone=0;
    while(alldone==0)
        fprintf('$ SELECT CALIBRATION METHOD\n')
%         fprintf('\t\t standard RGB\t\t1\n')
        fprintf('\t1... bit-stealing RGB\n')
        fprintf('\t2... BITS++ box\n')
        fprintf('\tx... none (exit)\n')
        gotone=lower(input(sprintf('\t>> '),'s'));
        alldone=ismember(gotone,'12x');
    end;
    switch gotone
        case '1'
            calFitRecord=pbCalibrateBitStealing();
        case '2'
             calFitRecord=pbCalibrateBITS();
        case 'x'
            calFitRecord=NaN;
    end; % switch   

