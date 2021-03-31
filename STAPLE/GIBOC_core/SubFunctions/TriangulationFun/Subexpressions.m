% ------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ w0 , w1 , w2 , f1 , f2 , f3 , g0 , g1 , g2 ] = Subexpressions (w0 , w1 , w2) 
%A Macro
%   Detailed explanation goes here

% [ w0 , w1 , w2 , f1 , f2 , f3 , g0 , g1 , g2 ] = Subexpressions (w0 , w1 , w2 , f1 , f2 , f3 , g0 , g1 , g2) 

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

