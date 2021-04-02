% FIT_ELLIPSE Finds the best fit to an ellipse for the given set of points.
%
% Note:     if an ellipse was not detected (but a parabola or hyperbola), then
%           an empty structure is returned
%
%   ellipse_t = fit_ellipse( x,y,axis_handle )
%
% Inputs:
%   x - a set of x points-coordinate in a column vectors.
%   y - a set of x points-coordinate in a column vectors.
%   axis_handle - optional. a handle to an axis, at which the estimated
%                 ellipse will be drawn along with it's axes.
%
% Outputs:   
%   ellipse_t - structure that defines the best fit to an ellipse
%                * a, sub axis (radius) of the X axis of the non-tilt ellipse
%                * b, sub axis (radius) of the Y axis of the non-tilt ellipse
%                * phi, orientation in radians of the ellipse (tilt)
%                * X0, center at the X axis of the non-tilt ellipse
%                * Y0, center at the Y axis of the non-tilt ellipse
%                * X0_in, center at the X axis of the tilted ellipse
%                * Y0_in, center at the Y axis of the tilted ellipse
%                * long_axis, size of the long axis of the ellipse
%                * short_axis, size of the short axis of the ellipse
%                * status, status of detection of an ellipse
%
%-------------------------------------------------------------------------%
%  Author:   Ohad Gal
%  Copyright 2003 Ohad Gal
%  see : https://fr.mathworks.com/matlabcentral/fileexchange/3215-fit_ellipse
%-------------------------------------------------------------------------%

function ellipse_t = fit_ellipse( x,y,axis_handle )
	% FIT_ELLIPSE Finds the best fit to an ellipse for the given set of points
	%
	% Note:     if an ellipse was not detected (but a parabola or hyperbola), then
	%           an empty structure is returned
	%
	% Parameters
	% ----------
	% x : __TYPE__
	% 	a set of x points
	% y : __TYPE__
	% 	a set of x points-coordinate in a column vectors.
	% axis_handle : __TYPE__
	% 	optional. a handle to an axis, at which the estimated
	% 	 ellipse will be drawn along with it's axes
	%
	% Returns
	% -------
	% ellipse_t : __TYPE__
	% 	structure that defines the best fit to an ellipse
	% 	 * a, sub axis (radius) of the X axis of the non-tilt ellipse
	% 	 * b, sub axis (radius) of the Y axis of the non-tilt ellipse
	% 	 * phi, orientation in radians of the ellipse (tilt)
	% 	 * X0, center at the X axis of the non-tilt ellipse
	% 	 * Y0, center at the Y axis of the non-tilt ellipse
	% 	 * X0_in, center at the X axis of the tilted ellipse
	% 	 * Y0_in, center at the Y axis of the tilted ellipse
	% 	 * long_axis, size of the long axis of the ellipse
	% 	 * short_axis, size of the short axis of the ellipse
	% 	 * status, status of detection of an ellips
	%
	%

	
	% initialize
	orientation_tolerance = 1e-3;
	
	% empty warning stack
	warning( '' );
	
	% prepare vectors, must be column vectors
	x = x(:);
	y = y(:);
	
	% remove bias of the ellipse - to make matrix inversion more accurate. (will be added later on).
	mean_x = mean(x);
	mean_y = mean(y);
	x = x-mean_x;
	y = y-mean_y;
	
	% the estimation for the conic equation of the ellipse
	X = [x.^2, x.*y, y.^2, x, y ];
	a = sum(X)/(X'*X);
	
	% check for warnings
	if ~isempty( lastwarn )
	    disp( 'stopped because of a warning regarding matrix inversion' );
	    ellipse_t = [];
	    return
	end
	
	% extract parameters from the conic equation
	[a,b,c,d,e] = deal( a(1),a(2),a(3),a(4),a(5) );
	
	% remove the orientation from the ellipse
	if ( min(abs(b/a),abs(b/c)) > orientation_tolerance )
	    
	    orientation_rad = 1/2 * atan( b/(c-a) );
	    cos_phi = cos( orientation_rad );
	    sin_phi = sin( orientation_rad );
	    [a,b,c,d,e] = deal(...
	        a*cos_phi^2 - b*cos_phi*sin_phi + c*sin_phi^2,...
	        0,...
	        a*sin_phi^2 + b*cos_phi*sin_phi + c*cos_phi^2,...
	        d*cos_phi - e*sin_phi,...
	        d*sin_phi + e*cos_phi );
	    [mean_x,mean_y] = deal( ...
	        cos_phi*mean_x - sin_phi*mean_y,...
	        sin_phi*mean_x + cos_phi*mean_y );
	else
	    orientation_rad = 0;
	    cos_phi = cos( orientation_rad );
	    sin_phi = sin( orientation_rad );
	end
	
	% check if conic equation represents an ellipse
	test = a*c;
	switch (1)
	case (test>0),  status = '';
	case (test==0), status = 'Parabola found';  warning( 'fit_ellipse: Did not locate an ellipse' );
	case (test<0),  status = 'Hyperbola found'; warning( 'fit_ellipse: Did not locate an ellipse' );
	end
	
	% if we found an ellipse return it's data
	if (test>0)
	    
	    % make sure coefficients are positive as required
	    if (a<0), [a,c,d,e] = deal( -a,-c,-d,-e ); end
	    
	    % final ellipse parameters
	    X0          = mean_x - d/2/a;
	    Y0          = mean_y - e/2/c;
	    F           = 1 + (d^2)/(4*a) + (e^2)/(4*c);
	    [a,b]       = deal( sqrt( F/a ),sqrt( F/c ) );    
	    long_axis   = 2*max(a,b);
	    short_axis  = 2*min(a,b);
	
	    % rotate the axes backwards to find the center point of the original TILTED ellipse
	    R           = [ cos_phi sin_phi; -sin_phi cos_phi ];
	    P_in        = R * [X0;Y0];
	    X0_in       = P_in(1);
	    Y0_in       = P_in(2);
	    
	    % pack ellipse into a structure
	    ellipse_t = struct( ...
	        'a',a,...
	        'b',b,...
	        'phi',orientation_rad,...
	        'X0',X0,...
	        'Y0',Y0,...
	        'X0_in',X0_in,...
	        'Y0_in',Y0_in,...
	        'long_axis',long_axis,...
	        'short_axis',short_axis,...
	        'status','' );
	else
	    % report an empty structure
	    ellipse_t = struct( ...
	        'a',[],...
	        'b',[],...
	        'phi',[],...
	        'X0',[],...
	        'Y0',[],...
	        'X0_in',[],...
	        'Y0_in',[],...
	        'long_axis',[],...
	        'short_axis',[],...
	        'status',status );
	end
	
	% check if we need to plot an ellipse with it's axes.
	
	
	% rotation matrix to rotate the axes with respect to an angle phi
	R = [ cos_phi sin_phi; -sin_phi cos_phi ];
	
	% the axes
	ver_line        = [ [X0 X0]; Y0+b*[-1 1] ];
	horz_line       = [ X0+a*[-1 1]; [Y0 Y0] ];
	new_ver_line    = R*ver_line;
	new_horz_line   = R*horz_line;
	
	% the ellipse
	theta_r         = linspace(0,2*pi,1000);
	ellipse_x_r     = X0 + a*cos( theta_r );
	ellipse_y_r     = Y0 + b*sin( theta_r );
	rotated_ellipse = R * [ellipse_x_r;ellipse_y_r];
	
	
	ellipse_t.data = rotated_ellipse;
	
	if (nargin>2) & ~isempty( axis_handle ) & (test>0)    
	    % draw
	    hold_state = get( axis_handle,'NextPlot' );
	    set( axis_handle,'NextPlot','add' );
	    plot( new_ver_line(1,:),new_ver_line(2,:),'r' );
	    plot( new_horz_line(1,:),new_horz_line(2,:),'r' );
	    plot( rotated_ellipse(1,:),rotated_ellipse(2,:),'r' );
	    set( axis_handle,'NextPlot',hold_state );
	end
