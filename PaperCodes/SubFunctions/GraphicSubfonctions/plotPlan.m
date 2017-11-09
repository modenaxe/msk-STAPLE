function plotPlan(n,d,Points,alphaV,colorV)
%Plot a rectangular plan
% n : normal of the plan
% d : constant d as in a.x + b.y + c.z + d = 0, if d is a vector then it's
% a point belonging to the plan
% Points list of points to get the length and width of the plan
% alphaV,colorV : Graphical parameters

if length(d)>2
    d = -dot(n,d);
end

if nargin < 4
    alphaV = 0.15;
    colorV = [1,0.65,0];
end

mX=min(Points(:,1))-10; MX=max(Points(:,1))+10;
mY=min(Points(:,2))-10; MY=max(Points(:,2))+10;
mZ=min(Points(:,3))-10; MZ=max(Points(:,3))+10;

[~,I]=max(abs(n));

if I==1
    Y=[mY mY MY MY];
    Z=[mZ MZ MZ mZ];
    X=(-n(2).*Y-n(3).*Z-d)/n(1);
    
elseif I==2
    X=[mX MX MX mX];
    Z=[mZ mZ MZ MZ];
    Y=(-n(1).*X-n(3).*Z-d)/n(2);
    
    
elseif I==3
    X=[mX MX MX mX];
    Y=[mY mY MY MY];
    Z=(-n(2).*Y-n(1).*X-d)/n(3);

end
fill3(X,Y,Z,colorV,'FaceAlpha',alphaV)


end

