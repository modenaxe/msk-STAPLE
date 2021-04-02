
% GETLARGERPLANARSECT Get the largest planar cross section,
% in term of area, in set of bone cross section. 
%
%   [TrProx, TrDist] = cutLongBoneMesh(TrLB, U_0, L_ratio)
%
% Inputs :
%   Curves - A Matlab structure containing a set of cross section
%            curves. 
%
% Outputs:
%   Curve - The cross section curve with the largest area among the set.
%   N_curves - The number of cross sections in the input structure.
%   Areas - A vector [1xN_curves] containing each section area.
%
%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  % 
% ----------------------------------------------------------------------- %

function [Curve, N_curves, Areas] = getLargerPlanarSect(Curves)
	% % GETLARGERPLANARSECT Get the largest planar cross section,
	% in term of area, in set of bone cross section.
	%
	% 
	%
	% Parameters
	% ----------
	% Curves : __TYPE__
	% 	A Matlab structure containing a set of cross section
	% 	 curves.
	%
	% Returns
	% -------
	% Curve : __TYPE__
	% 	The cross section curve with the largest area among the set.
	% N_curves : __TYPE__
	% 	The number of cross sections in the input structure.
	% Areas : __TYPE__
	% 	A vector [1xN_curves] containing each section area.
	% 	
	% 	-------------------------------------------------------------------------
	% 	 Copyright (c) 2020 Modenese L. 
	% 	 Author: Luca Modenese 
	% 	 email: l.modenese@imperial.ac.uk  
	% 	 -----------------------------------------------------------------------
	%
	%


    N_curves = length(Curves);

    % check to use just the tibial curve, as in GIBOK
    for nc = 1: N_curves
        Areas(nc) = Curves(nc).Area;
    end
    [~, ind_max_area] = max(Areas);
    Curve = Curves(ind_max_area);

end