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
%
% ------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ CovM ] = TriCovMatrix( TR )
    
    % Get 2D properties of the triangulation object
    Ppt = TriMesh2DProperties(TR);

    % Area of each triangle and total area of triangulation
    W = Ppt.Area;
    WTot = Ppt.TotalArea;

    % Center point of each triangle
    Pts = TR.incenter;

    % Compute each element of the covariance matrix
    CovM = zeros(3);
    for i=1:3
        for j=1:3
            CovM(i,j) = sum((Pts(:,i)-mean(Pts(:,i))).*(Pts(:,j)-mean(Pts(:,j))).*W)/WTot;
        end
    end

end

