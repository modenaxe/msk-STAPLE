function pl3tVectors( Center , Vctrs , VctrLength )
%Automatic quiver plot of vectors, vectors must be presented as column
%   Vctrs : 3xN matrix
% VctrLength : scalar ; representing the 'scale' input of quiver3
if nargin < 3
    VctrLength = 50;
end

if size(Vctrs,2)>size(Vctrs,1)
    Vctrs = transpose(Vctrs);
end
for i = 1:size(Vctrs,2)
    quiver3(Center(1),Center(2),Center(3),Vctrs(1,i),Vctrs(2,i),Vctrs(3,i),VctrLength,'LineWidth',5)
end

end

