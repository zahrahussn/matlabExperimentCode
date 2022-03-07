% simpledemo.m

try
    AssertOpenGL;
    s = max(Screen('Screens'));
    fprintf('max screen = %d\n', s);
    fprintf('successful completion\n');
catch
    Screen('CloseAll');
    fprintf('caught error\n');
    rethrow(lasterror);
end
