function [ Centroid, Area ] = PlanPolygonCentroid3D( Pts )   
    % Find the centroid of a 2D Polygon.
    %
    % The 2D polygon can be embedded in a 3D space, and must described 
    % by its a close curve in a 3D space.
    % Works with arbitrary shapes (convex or not).
    % 
    % Args:
    %   Pts ([n x 3] or [n x 2] floats matrix): A matrix describing the 2D polygon boundary closed curve
    % Returns:
    %   BufferedFileStorage: A buffered writable file descriptor
    %   Test : Tested  

    % :param Pts: A matrix describing the 2D polygon boundary closed curve
    % :type PTs: (n x 3) or (n x 2) floats matrix
    % :returns:
    %   - **Centroid** is the centroid of the 2D polygon
    %   - **Area** is the area (surface) of the 2D polygon 



    % :return: Centroid: the centroid of the 2D polygon
    % :rtype: (1x3) floats matrix
    % :return: Area: the area (surface) of the 2D polygon
    % :rtype: float

    if isequal(size(Pts), [0, 0])
        warning('PlanPolygonCentroid3D.m Empty Pts variable.')
        Centroid = nan;
        Area = nan;
        return
    end

    % Close the curve if not closed
    if Pts(1,:) ~= Pts(end,:)
        Pts(end+1,:) = Pts(1,:);
    end

    % Initial Guess of center
    Center0 = mean(Pts(1:end-1,:));

    % Middle Point of each polygon side
    PtsMiddle = Pts(1:end-1,:) + diff(Pts)/2;

    % Get the centroid of each points connected
    TrianglesCentroid  = PtsMiddle - 1/3*bsxfun(@minus,PtsMiddle,Center0);

    %Get the area of each triangles
    [V,~] = eig(cov(Pts(1:end-1,:)));
    n= V(:,1); % normal to polygon plan

    TrianglesArea =1/2*cross(diff(Pts),-bsxfun(@minus,Pts(1:end-1,:),Center0))*n;

    % Barycenter of triangles
    Centroid = sum(TrianglesCentroid.*repmat(TrianglesArea,1,3))/sum(TrianglesArea);

    if nargout>1
        Area = abs(sum(TrianglesArea));
    end


end

