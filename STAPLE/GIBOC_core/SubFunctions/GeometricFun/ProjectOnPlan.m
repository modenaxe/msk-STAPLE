% PROJECTONPLAN project points Pts on a plan describe by its normal n and
% a point on the plan.
%
% [ Pts_Proj ] = ProjectOnPlan( Pts , n , Op )
%
% Inputs:
%   Pts - Initial set of m certain condyle points formated as [mx3]
%                  matrix
%   n - Plan normal [3x1]
%   Op - A point on the plan 
% Outputs:
%   Pts_Proj - Points projected on the plan
%
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%

function [ Pts_Proj ] = ProjectOnPlan( Pts , n , Op )
	% PROJECTONPLAN project points Pts on a plan describe by its normal n and
	% a point on the plan
	%
	% 
	%
	% Parameters
	% ----------
	% Pts : [nx3] float matrix
	% 	Initial set of m certain condyle points formated as [mx3]
	% 	 matrix
	% n : [3x1] float vector
	% 	Plan normal [3x1]
	% Op : [1x3] float vector
	% 	A point on the plan
	%
	% Returns
	% -------
	% Pts_Proj : [nx3] float matrix
	% 	Points projected on the pla
	%
	%

	
	if length(Op)==1
	    Op = [0 0 -Op(1)/n(3)]; %Origin points of plan
	end
	OpPts = bsxfun(@minus,Pts,Op); %Create vector Pts origin of plan Op
	Pts_Proj = Pts - (OpPts*n)*n'; % Substract Pts
	end
	
