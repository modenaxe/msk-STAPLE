function [ TRout ] = TriDilateMesh( TRsup, TRin, nbElmts )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

[~, ia ,ic] = intersect(TRsup.Points,TRin.Points,'rows','stable');

ElmtsOK = TRsup.vertexAttachments(ia)';
ElmtsOK = transpose(unique(horzcat(ElmtsOK{:})));
ElmtsInitial = ElmtsOK;

for i = 1:nbElmts
    ElmtNeighbours = unique(NotNaN(TRsup.neighbors(ElmtsInitial)));
    ElmtsInitial = unique(ElmtNeighbours);
    ElmtsOK = unique([ ElmtsOK ; ElmtsInitial ]);
end

TRout = TriReduceMesh( TRsup, ElmtsOK);

end

function [Y] = NotNaN(X)
% Keep only not NaN elements of a vector
Y = X(~isnan(X));
end