% TRICOVMATRIX Compute the weighted Cov matrix of a triangulation by 
% taking the triangle incenters and weighting them by the area of their 
% corresponding triangle.
% The eigen vectors of the output covariance matrix are the principal inertia 
% of the triangulation under the assumption that it is hollow and the
% surfacic mass is homogenous.
% 
% [ CovM ] = TriCovMatrix( TR )
%
% Inputs:
%   TR - A triangulation object.
%   
% Outputs:
%   CovM - A weighted by area 3x3 covariance matrix object of the TR.
%
%
% See also TRIMESH2DPROPERTIES
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ CovM ] = TriCovMatrix( TR )
%Compute the weighted Cov matrix of a triangulation by taking the triangle
%center and weighting them by their corresponding area

Ppt = TriMesh2DProperties(TR);

W = Ppt.Area;
WTot = Ppt.TotalArea;

CovM = zeros(3);

Pts = TR.incenter;

for i=1:3
    for j=1:3
        CovM(i,j) = sum((Pts(:,i)-mean(Pts(:,i))).*(Pts(:,j)-mean(Pts(:,j))).*W)/WTot;
    end
end



end

