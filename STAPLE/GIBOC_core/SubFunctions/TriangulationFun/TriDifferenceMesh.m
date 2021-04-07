% TRIDIFFERENCEMESH Boolean difference between original triangulation object
% TR1 and another triangulation object TR2.
% The function output a triangulation object based on TR1 except that all 
% triangles of TR1 that contain a vertex of TR2 are removed.
% 
% [ TRout ] = TriDifferenceMesh( TR1 , TR2 )
% 
% Inputs:
%   TR1 - A triangulation object.
%   TR2 - A triangulation object to substract from TR1.
%   
% Outputs:
%   TRout - A triangulation object resulting of the boolean difference 
%           of TR1 and TR2
%
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ TRout ] = TriDifferenceMesh( TR1 , TR2 )


[~, ia , ~] = intersect(TR1.Points,TR2.Points,'rows','stable');

if isempty(ia)
    warning('No intersection found, the tolerance distance has been set to 1E-5')
    [~, ia , ~] = intersect(round(TR1.Points,5),round(TR2.Points,5),...
        'rows','stable');
end

Elmts2Delete = TR1.vertexAttachments(ia)';
ElmtsAll = ones(length(TR1.ConnectivityList),1);

Elmts2Keep = ElmtsAll;
Elmts2Keep(unique(horzcat(Elmts2Delete{:}))) = 0;
Elmts2KeepID = find(Elmts2Keep);
TRout = TriReduceMesh( TR1, Elmts2KeepID);


end

