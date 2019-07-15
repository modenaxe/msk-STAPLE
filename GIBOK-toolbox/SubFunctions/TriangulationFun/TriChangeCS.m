function [ TrNewCS, V ,T ] = TriChangeCS( Tr, V, T )
%TriChangeCS Change the triangulation coordinate system
%   If only one argument is provided Tr is moved to its principal inertia
%   axis CS

% If new basis matrices and translation vector is not provided the PIA of
% the shape are calculated to move it to it.
if nargin == 1
    [ V, T ] = TriInertiaPpties( Tr );
elseif nargin == 2
    error('Wrong number of input argument, 1 ? move to PIA CS, 3 move to CS defined by V and T')
end

% Translate the point by T
Pts_T = bsxfun(@minus , Tr.Points , T');

% Rotate the points with V
Pts_T_R = Pts_T*V; % Equivalent to (V\Pts_T')'

%Construct the new triangulation:
TrNewCS = triangulation(Tr.ConnectivityList , Pts_T_R);



end

