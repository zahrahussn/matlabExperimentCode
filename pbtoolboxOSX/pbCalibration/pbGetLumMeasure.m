function inStr=pbGetLumMeasure(timeout);
% 
% function inStr=pbGetLumMeasure(timeout);
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
        inStr = PR650serialread;
    end

    if waited == timeout
        error('No response after measure command');
    end
    
return
