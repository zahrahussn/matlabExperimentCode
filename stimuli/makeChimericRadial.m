
stim=3;
savejpeg=0;

% leaves
if stim==3
    f3 = [10,12,15,20,30];
    phiRot=10;
    nf3 = length(f3);
    adj=0;
    for i = 1:nf3
        stim=makeRadialStim([3,5,f3(i)],[10,10,5],[0,0,0]); %leaf
        % stim=flipud(stim);
    end
end

% butterflies
if stim==2
    A3 = [-40,-20,0, 20,40];
    phiRot=10;
    nA3 = length(A3);
    adj=0;
    for i = 1:nA3
        butter.("stim"+num2str(i))=makeRadialStim([2 3 4 10],[10 10*(100+A3(i))/100 30 2],...
                            [180,180+phiRot,180+phiRot,0],0);
   % stim=makeRadialStim([2,3,4,5,10],[10,30,20,5,7],[180,180+10,180+10,10,180]);
    butter.("stim"+num2str(i))=flipud(butter.("stim"+num2str(i)));
    end
    for i = 1:5
        tmpstim=butter.(['stim',num2str(i)]);
        mbutter=fliplr(tmpstim);
        tmpl=tmpstim(:, 1:(256/2)+adj);
        tmpr=tmpstim(:, ((256/2)+1)+adj: 256);
    
        leftchim=[tmpl fliplr(tmpl)];
        rightchim=[fliplr(tmpr) tmpr];
        
        figure;
        imshow(Scale([leftchim,tmpstim, rightchim]));
        %pause(2)
        
        if savejpeg==1
            imwrite(Scale(tmpstim),['butter', num2str(i),'.jpeg'],'JPEG');
            imwrite(Scale(mbutter),['butter_m', num2str(i), '.jpeg'],'JPEG');
            imwrite(Scale(leftchim),['butter_LL', num2str(i), '.jpeg'],'JPEG');
            imwrite(Scale(rightchim),['butter_RR', num2str(i),'.jpeg'],'JPEG');
        end

    end
end

% heads
if stim==1
    A3 = [-40, -20,0,20, 40];
    A4 = [100];
    nA3 = length(A3);
    nA4 = length(A4);
    phiRot=20;
    for i = 1:nA3
       for j = 1:nA4
           head.("stim"+num2str(i))=makeRadialStim([1 2 3 4 5 6 7],[7 20 5*(100+A3(i))/100 1*(100+A4(j))/100  0.4  0.5 0.3],...
                            [0 0 180+phiRot 0+phiRot 180-0.15*phiRot 180 180],0);
           head.("stim"+num2str(i))=flipud(head.("stim"+num2str(i)));
       end
    end
    
    
    adj=0;
    rot=0;
    mid=0;
    for i = 1:5
        tmpstim=head.(['stim',num2str(i)]);
        mhead=fliplr(tmpstim);
        tmpl=tmpstim(:, 1:(256/2)+adj);
        tmpr=tmpstim(:, ((256/2)+1)+adj: 256);
    
        leftchim=[tmpl fliplr(tmpl)];
        rightchim=[fliplr(tmpr) tmpr];
    
        imshow(Scale([leftchim,tmpstim, rightchim]));
        pause(2)
    
        if savejpeg==1
            imwrite(Scale(tmpstim),['head', num2str(i),'.jpeg'],'JPEG');
            imwrite(Scale(mhead),['head_m', num2str(i), '.jpeg'],'JPEG');
            imwrite(Scale(leftchim),['head_LL', num2str(i), '.jpeg'],'JPEG');
            imwrite(Scale(rightchim),['head_RR', num2str(i),'.jpeg'],'JPEG');
        end

    end

end



    
