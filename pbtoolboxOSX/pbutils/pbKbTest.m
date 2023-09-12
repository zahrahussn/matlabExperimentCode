
keyIsDown=0;
FlushEvents('keyDown');
while (keyIsDown==0)
    WaitSecs(0.001);
    [keyIsDown,secs,keyCode] = KbCheck();
end;
    FlushEvents('keyDown');
    fprintf('\n key pressed = %i\n',);
    if (keyIsDown)
        theKeys=find(keyCode==1)
        if (length(theKeys)==1)&& max(ismember(goodKeys,theKeys(1)))==1
            alldone=1;
            clc;
        end;
        FlushEvents('keyDown');
    end;
end;
