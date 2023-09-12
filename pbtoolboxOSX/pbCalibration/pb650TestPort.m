function pb650TestPort(portNumber)
    % pb650TestPort(portNumber)
    % 
    timeout = 5;
    fprintf('make sure photometer is turned on and plugged in\n');
    fprintf('hit any key to continue...\n')
    WaitSecs(0.5);
    while(KbCheck==0)
    end;

    fprintf('\t$trying to open port %i...\n',portNumber);
    SerialComm('open', portNumber, '9600,n,8,1');
    SerialComm('hshake',portNumber,'n');
    SerialComm('close', portNumber);
    WaitSecs(0.5);
    SerialComm('open', portNumber, '9600,n,8,1');
    SerialComm('hshake',portNumber,'n');

    % Send set backlight command to high level to check
    % whether we are talking to the meter.
    fprintf('\t$trying to write to port %i...\n',portNumber);
    SerialComm('write', portNumber, ['b3' char(10)]);
 
    fprintf('\t$looking for a response on port %i...\n',portNumber);

    retval = [];
    starttime=GetSecs;
    while (isempty(retval) & timeout>GetSecs-starttime)

    % Look for any data on the serial port.
    retval = char(SerialComm('read',portNumber))';

    % If data exists keep reading off the port until there's nothing left.
    if ~isempty(retval)
        tmpData = 1;
        while ~isempty(tmpData)
            WaitSecs(0.050);
            tmpData = char(SerialComm('read', portNumber))';
            retval = [retval, tmpData];
        end
    end


    end
    fprintf('\t$closing port %i...\n',portNumber);
    SerialComm('close', portNumber);

    [y,ok]=str2num(retval);
    if (ok==0)
        fprintf('failed to connect to photometer. try another port number\n');
    else
         fprintf('connected to photometer!\n');
    end;  



