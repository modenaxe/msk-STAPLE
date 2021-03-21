function [closestPtPair, isolatedPt, maxEdgeLength, minEdgeLength] = ...
                                        TriangleClosestPointPair(triangle)
    % Identify the pair of closest point of the triangles
    %
    % :param triangle: A triangle described by 3 points
    % :type triangle: (3 x 3) or (3 x 2) floats matrix
    % :return: closestPtPair: the centroid of the 2D polygon
    % :rtype: (1x3) floats matrix
    %
    %
    %
    %   Input:
    %       triangle:   a 3x3 matrix or 3x2 matrix
    %                   3 lines of the 2D or 3D coordinates of the vertices of
    %                   the triangle
    %
    %   Output:
    %       closestPtPair:  a 2x3 or 2x2 matrix of the pair of closest
    %                           point
    %       isolatedPt:     a 1x3 or 1x2 vector of the coordiante of the
    %                           point isolated relative to the point pair
    %       minEdgeLength:  a scalar value
    %       maxEdgeLength:  a scalar value
    % :param Pts: A matrix describing the 2D polygon boundary closed curve
    % :type PTs: (n x 3) or (n x 2) floats matrix
    % :return: Centroid: the centroid of the 2D polygon
    % :rtype: (1x3) floats matrix
    % :return:Area: the area (surface) of the 2D polygon
    % :rtype: float


    % Get edge length

    triangleS = [triangle; triangle(1,:)];
    edgeLengths = sqrt( sum( diff(triangleS, 1).^2 , 2) );

    % Get the smallest edge
    [minEdgeLength,i] = min(edgeLengths);

    % The smallest edge connect the two closest point of the triangle
    closestPtPair = triangleS(i:i+1,:);

    % The isolated point is the 
    j = i+2;
    if j > 4
        j = i-1 ;
    end
    isolatedPt = triangleS(j,:) ;
    maxEdgeLength = max(edgeLengths);


end

