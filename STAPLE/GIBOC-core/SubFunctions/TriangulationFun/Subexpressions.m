% SUBEXPRESSION Macro used in the computation of discrete volume integrals
%
%   [ w0 , w1 , w2 , f1 , f2 , f3 , g0 , g1 , g2 ] = Subexpressions (w0 , w1 , w2)
%
% Pseudo Code by : David Eberly, Geometric Tools, Redmond WA 98052
% See the link below for more information
% https://www.geometrictools.com/Documentation/PolyhedralMassProperties.pdf
% This work is licensed under the Creative Commons Attribution 4.0 International License. To view a copy
% of this license, visit http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative Commons,
% PO Box 1866, Mountain View, CA 94042, USA.
% Created: December 31, 2002
% Last Modified: November 3, 2009
%
% See also : TRIINERTIAPPTIES
%
% ------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ w0 , w1 , w2 , f1 , f2 , f3 , g0 , g1 , g2 ] = Subexpressions (w0 , w1 , w2) 
    temp0 = (w0 + w1);
    f1 = temp0 + w2;
    temp1 = w0*w0 ;
    temp2 = temp1 + w1*temp0 ;
    f2 = temp2 + w2*f1 ;
    f3 = w0*temp1 + w1*temp2 + w2*f2 ;
    g0 = f2 + w0*( f1+w0 );
    g1 = f2 + w1*( f1+w1 );
    g2 = f2 + w2*( f1+w2 ) ;
end

