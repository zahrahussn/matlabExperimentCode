function [qual,L,U,V]=pbMeasureLuminance
% Make a luminance measurement:

    global g_serialPort;

    % Check for initialization
    if isempty(g_serialPort)
       error('Meter has not been initialized.');
    end
    portNumber = g_serialPort;
    % Initialize
    timeout = 30;
    % See if we can sync to the source
    % and set sync mode appropriately.
    syncFreq = PR650getsyncfreq;
    if ~isempty(syncFreq)
        pb650setsyncfreq(1);
    else
        pb650setsyncfreq(0);
    end

    readStr=pb650GetLumMeasure(timeout);
    
    
    
    % fprintf('Got data\n');
    qual = sscanf(readStr, '%f', 1);
		 
    % Check for sync mode error condition.  If get one,
    % turn off sync and measure again.
    if qual == 7 || qual == 8
        pb650setsyncfreq(0);
        readStr = pb650GetLumMeasure(timeout);
        qual = sscanf(readStr, '%f', 1);
    end
	
    % Check for other error conditions
    if qual == -1 || qual == 10
        %disp('Low light level during measurement');
        %disp('Setting returned value to zero');
        L=0;
        U=0;
        V=0;
    elseif qual == 18 || qual == 0
        units = str2num(readStr(4));
        if units ~= 0
            error('Units not returned as cd/m2');
        end
        L = str2num(readStr(6:14));
        U = str2num(readStr(16:20));
        V = str2num(readStr(22:26));
    elseif (qual ~= 0)
      error('Bad return code %g from meter',qual);
    end	

return
