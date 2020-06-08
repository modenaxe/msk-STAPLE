% coeff_reduc: if you specify r as 0.2, then the number of faces is reduced to 20% of the number in the original patch
function reducedTriObj = reduceTriObjGeometry(boneTriObj, coeff_reduc)
% default reduction is 30%
if nargin<2; coeff_reduc = 0.3; end
% transform triangulation in patch
[TriPatch.vertices, TriPatch.faces] = deal(boneTriObj.Points, boneTriObj.ConnectivityList);
% reduce patch
[nf,nv] = reducepatch(TriPatch, coeff_reduc);
% back to triang
reducedTriObj = triangulation(nf,nv);
end