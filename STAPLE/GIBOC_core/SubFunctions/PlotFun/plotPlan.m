% PLOTPLAN Plot a plan (filled rectangle) on the current axis.
%
% plotPlan(n, Op, Points, alpha, color)
%
% Inputs:
%   n - An unit normal vector of the plan.
%   Op - A point located on the plan.
%   Points - A set of points to provide the dimension of the plotted plan.
%            All those points when projected onto the plan will be within
%            the plotted plan.
%   alpha - Matlab transparency factor for plotted plan.
%   color - Color of the plan.
% 
% Outputs:
%   None - Plot a plan (filled rectangle) on the current axis.
%
%
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function plotPlan(n, Op, Points, alpha, color)


if length(Op)>2
    d = -dot(n,Op);
else
    d = Op
end

if nargin < 4
    alpha = 0.15;
    color = [1,0.65,0];
end

Points = ProjectOnPlan( Points , n , Op )
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
fill3(X, Y, Z, color, 'FaceAlpha',alpha)


end

