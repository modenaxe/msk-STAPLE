function [ Vnormalized ] = normalizeV( V )
% NORMALIZEV Normalize the vector or list of vectors V
% First transpose v if necessary to get a  

if min(size(V)) == 1
    if size(V,1) ~= length(V)
        V = V';
    end
    Vnormalized = V / norm(V);
    
elseif size(V,1) == size(V,2)
    error('input matrix is squared we can not tell if vector are in columns or lines')
else
    if  size(V,1) ~= length(V)
        V = V';
    end
    Vnorm = sqrt(sum(V.^2,2));
    Vnormalized = V./repmat(Vnorm,1,3);
end

end

