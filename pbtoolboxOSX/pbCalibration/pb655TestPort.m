function pb655TestPort()
    % pb650TestPort(portNumber) % adapted from pb650TestPort Sept 2013, zh
    % 
    timeout = 5;
    fprintf('make sure photometer is turned on and plugged in\n');
    fprintf('hit any key to continue...\n')
    WaitSecs(0.5);
    while(KbCheck==0)
    end;

    global g_serialPort;
    portNumber = FindSerialPort('usbmodem', 1);
    g_serialPort = IOPort('OpenSerialPort', portNumber);
    
    rm = 'PHOTO';
    for i = 1:5
        IOPort('write', g_serialPort, rm(i));
    end
   
    retval = [];
    starttime=GetSecs;
    while (isempty(retval) & timeout>GetSecs-starttime)

    % Look for any data on the serial port.
    % retval = char(SerialComm('read',portNumber))'; % for PR650
    retval = char(IOPort('read', g_serialPort)); % for PR655

    % If data exists keep reading off the port until there's nothing left.
    if ~isempty(retval)
        tmpData = 1;
        while ~isempty(tmpData)
            WaitSecs(0.050);
            % tmpData = char(SerialComm('read', portNumber))'; % pr650
            tmpData =  char(IOPort('read', g_serialPort)); % pr655
            retval = [retval, tmpData]; %#ok<AGROW>
        end
    end


    end
    fprintf('\t$closing port %i...\n',portNumber);
    %SerialComm('close', portNumber);
    IOPort('close', g_serialPort);
    g_serialPort = [];

    [y,ok]=str2num(retval);
    if (ok==0)
        fprintf('failed to connect to photometer. try another port number\n');
    else
         fprintf('connected to photometer!\n');
    end;  



