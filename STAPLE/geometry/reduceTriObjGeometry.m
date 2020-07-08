% REDUCETRIOBJGEOMETRY Reduce the number of faces of a MATLAB triangulation
% object. This function is normally employed before printing OBJ files to
% reduce their size and make the visualization in OpenSim faster.
% The function simply employs the reducepatch function available in MATLAB.
%
%   reducedTriObj = REDUCETRIOBJGEOMETRY(boneTriObj, coeff_reduc)
%
% Inputs:
%   boneTriObj - a MATLAB triangulation object. Normally represents a bone
%       geometry in this set of scripts.  
%
%   coeff_reduc - a number between zero and one indicating the desidered
%       reduction of faces. For example, if you specify r as 0.2, the 
%       number of faces of the original MATLAB triangulation object is 
%       reduced to 20% of the number in the original patch. 
%
% Outputs:
%   reducedTriObj - a triangulation object obtained from boneTriObj after
%      reducing the number of faces according to the specified coeff_reduc. 
%
% See also REDUCEPATCH.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
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