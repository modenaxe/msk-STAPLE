function [  ] = pl3t( P, varargin)
% pl3t( P, c) Plot 3D of points P with color and marker c 
% Simplification of the plot3 function for use 
% with matrices of points coordinates
% Do not work for matrices 3x3 as the lines or columns coordinate vector cannot be descrimined

numInputs = length(varargin);

if min(size(P))==1
    X=P(1);
    Y=P(2);
    Z=P(3);
else
    if size(P,1)>3
        X=P(:,1);
        Y=P(:,2);
        Z=P(:,3);
    elseif size(P,1) == 2 && size(P,2) == 3
        X=P(:,1);
        Y=P(:,2);
        Z=P(:,3);
    else
        X=P(1,:);
        Y=P(2,:);
        Z=P(3,:);
    end
end

if isempty(varargin)
    plot3(X,Y,Z,'b.')
else
    plot3(X,Y,Z,varargin{1:numInputs})
end


axis equal

end
