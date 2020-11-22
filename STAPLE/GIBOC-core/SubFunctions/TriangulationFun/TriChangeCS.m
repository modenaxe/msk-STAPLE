% TRICHANGECS Change the triangulation coordinate system
% If only one argument is provided Tr is moved to its principal inertia
% axis (PIA) CS
% If new basis matrices and translation vector is not provided the PIA of
% the triangulation are calculated to move it to it.
%
%   [ TrNewCS, V ,T ] = TriChangeCS( Tr, V, T )
%
% Inputs:
%   Tr - A triangulation object. Needs to be closed (watertight) if 
%        only one argument is passed to the function
%   V [optional] - The 3x3 matrix of the new coordinate system
%   T [optional] - The 3x1 vector of translation to apply 
%   
% Outputs:
%   TrNewCS - The triangulation object in the new coordinate system
%   V [optional] - The 3x3 matrix of the new coordinate system bais
%   T [optional] - The 3x1 vector of translation applied
%
%
% See also TRIINERTIAPPTIES
%
% ------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ TrNewCS, V ,T ] = TriChangeCS( Tr, V, T )
    if nargin == 1
        [ V, T ] = TriInertiaPpties( Tr );
    elseif nargin == 2
        error('Wrong number of input argument, 1 ? move to PIA CS, 3 move to CS defined by V and T')
    end

    % Translate the point by T
    Pts_T = bsxfun(@minus , Tr.Points , T');

    % Rotate the points with V
    % COMMENT FROM LUCA:
    %-------------------------------
    % Tr.Points = Pts_T = n x 3
    % V = [3x3]
    % Pts_T = [n x 3]
    % T = Origin = [1 x 3]
    %-------------------------------
    % P_new_RF = ((RotNew2Old)' * (Pts_T)')'
    % in my case, when I want to use it for transforming in ISB ref syste
    % P_ISB = ((RotISB2Glob)' * (Pts_T)')'
    Pts_T_R = Pts_T*V; % Equivalent to (V'*Pts_T')'

    %Construct the new triangulation:
    TrNewCS = triangulation(Tr.ConnectivityList , Pts_T_R);
end

