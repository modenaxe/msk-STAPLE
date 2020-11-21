% LOGCONSOLEPRINTOUT Set up a diary for storing and printing the command
% window printout of the STAPLE workflows.
%
%   logConsolePrintout(log_status, log_file_path)
%
% Inputs:
%   log_status -  string that sets the MATLAB diary on or off. Acceptable
%       values: 'on' (switches on the diary) and 'off' (switches off the 
%       diary)
%
%   log_file_path - string of the name, including path, of the log file.
%
% Outputs:
%   no output.
%
%
% See also DIARY, FCLOSE.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
function logConsolePrintout(log_status, log_file_path)

switch log_status
    case 'on'
        if nargin<2
            warning('logConsolePrintout.m No log file specified. Saving to ''./autofile.log''')
            log_file_path = './autofile.log'; 
        end
        % cleaning file (otherwise it appends)
        fopen(log_file_path,'w+');
        % close all files in case some are open because of scripts
        % partially run
        fclose all;
        diary(log_file_path);
    case 'off'
        diary off
        fclose all;
    otherwise
        error('logConsolePrintout.m  Please specify a status for logging: ''on'' or ''off''');
end