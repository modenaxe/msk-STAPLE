% CONVERTBOOLEAN2ONOFF Returns a printable string for active/inactive
% options.
%
%   onoff = convertBoolean2OnOff(bool_var)
%
% Inputs:
%   bool_var - a MATLAB boolean value (0: false or 1: true).
%
% Outputs:
%   onoff - a string indicating if the option is 'on' or 'off'.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese  
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
function onoff = convertBoolean2OnOff(bool_var)

if bool_var==1 || bool_var==0
    if bool_var
        onoff = 'on';
    else
        onoff = 'off';
    end
else
    error('convertBoolean2OnOff.m Input should be a boolean: 1 or 0.')
end

end