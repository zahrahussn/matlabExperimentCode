function readStr=pb650GetLumMeasure(timeout);
% 
% function inStr=pb650GetLumMeasure(timeout);
% 

    global g_serialPort;

    % Check for initialization
    if isempty(g_serialPort)
       error('Meter has not been initialized.');
    end
    portNumber = g_serialPort;

    SerialComm('write',portNumber,['m3' char(10)]);
    waited = 0;
    inStr = [];
    while isempty(inStr) && (waited < timeout)
        WaitSecs(1);
        waited = waited+1;
        inStr = pb650serialread;
    end

    if waited == timeout
        error('No response after measure command');
    end

    
    

    SerialComm('write', g_serialPort, ['d3' char(10)]);
    WaitSecs(0.1);
    waited = 0;
    inStr = [];
    while isempty(inStr) && (waited < timeout)
        inStr = pb650serialread;
        WaitSecs(1);
        waited = waited+1;
    end

    if waited == timeout
       error('Unable to get reading from radiometer');
    else
    % Pick up entire buffer.  This is the loop referred to above.
        readStr = inStr;
        while ~isempty(inStr)
            inStr = pb650serialread;
            readStr = [readStr inStr];
        end
    end

return
