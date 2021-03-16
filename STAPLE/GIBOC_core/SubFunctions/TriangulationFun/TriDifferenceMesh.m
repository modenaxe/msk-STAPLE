% ------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ TRout ] = TriDifferenceMesh( TR1 , TR2 )
%Boolean difference between original mesh TR1 and another mesh TR2
%   Detailed explanation goes here
% /!\ delete all elements in TR1 that contains a node in TR2

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

