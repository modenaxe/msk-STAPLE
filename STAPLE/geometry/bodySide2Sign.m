% BODYSIDE2SIGN Returns a sign and a mono-character, lower-case string
% corresponding to a body side. Used in several STAPLE functions for:
% 1) having a standard side label
% 2) adjust the reference systems to the body side.
%
%   [sign_side, side_low] = bodySide2Sign(side_raw)
%
% Inputs:
%   side_raw - generic string identifying a body side. 'right', 'r', 'left' 
%       and 'l' are accepted inputs, both lower and upper cases.
%
% Outputs:
%   sign_side - sign to adjust reference systems based on body side. Value:
%       1 for right side, Value: -1 for left side.
%
%   side_low - a single character, lower case body side label that can be 
%           used in all other STAPLE functions requiring such input.
%
% See also INFERBODYSIDEFROMANATOMICSTRUCT.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function [sign_side, side_low] = bodySide2Sign(side_raw)

side_low = lower(side_raw(1));

switch side_low
    case 'r'
        sign_side = 1;
%     case 'right'
%         sign_side = 1;
    case 'l'
        sign_side = -1;
%     case 'left'
%         sign_side = -1;
    otherwise
        error 'bodySide2Sign.m Error: specify right ''r'' or left ''r'''
end


