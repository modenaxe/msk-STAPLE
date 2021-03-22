
function [ Pts_Proj ] = ProjectOnPlan( Pts , n , Op )
	% __NOTDONEYET__summaryline
	%
	% __NOTDONEYET__extended_description
	%
	% Parameters
	% ----------
	% Pts : [nx3] float matrix
	% 	__DESCRIPTION__
	% n : [3x1] float vector
	% 	An unit normal vector
	% Op : [1x3] float vector
	% 	A point located on the plan
	%
	% Returns
	% -------
	% Pts_Proj : [nx3] float matrix
	% 	__DESCRIPTION__
	%


	%ProjectOnPlan : project points Pts on a plan describe by its normal n and
	%the altitude d
	if length(Op)==1
	    Op = [0 0 -Op(1)/n(3)]; %Origin points of plan
	end
	OpPts = bsxfun(@minus,Pts,Op); %Create vector Pts origin of plan Op
	Pts_Proj = Pts - (OpPts*n)*n'; % Substract Pts

end