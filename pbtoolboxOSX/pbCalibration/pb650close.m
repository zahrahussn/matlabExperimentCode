function pb650close
% pb650close
%
% Close serial port used to talk to colorimeter.  Reset
% serial global.
%

global g_serialPort;


if ~isempty(g_serialPort)
   SerialComm('close', g_serialPort);
   g_serialPort = [];
end
