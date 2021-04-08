% PL3TVECTORS Plot 3D vectors on current axis.
% The 3D vector(s) share a common origin point and length. 
% The direction of each vector is provided in a matrix
%
% pl3tVectors( Origin , Vctrs , VctrLength )
%
% Inputs:
%   Origin - Origin point of each vector.
%   Vctrs - A matrix of vectors direction.
%   Length - The length of the vector(s) on the plot.
% 
% Outputs:
%   None - Plot the vector(s) on the current axis
%
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function pl3tVectors( Origin , Vctrs , Length )


    if nargin < 3
        Length = 50;
    end

    if size(Vctrs,2)>size(Vctrs,1)
        Vctrs = transpose(Vctrs);
    end
    for i = 1:size(Vctrs,2)
        quiver3(Origin(1),Origin(2),Origin(3),Vctrs(1,i),Vctrs(2,i),Vctrs(3,i),Length,'LineWidth',5)
    end

end

