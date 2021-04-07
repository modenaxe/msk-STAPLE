% TRIKEEPLARGESTPATCH Keep the largest (by area) connected patch of a 
% triangulation object.
% 
% Here, two triangles are considered connected if they share an edge :
%   Single vertex         Nothing              Edge(s)
%         |                  |                    |
%         V                  V                    V
%   Not connected       Not connected         Connected
%       |\  /|            |\    /|               /|\ 
%       | \/ |            | \  / |              / | \
%       | /\ |            | /  \ |              \ | /\
%       |/  \|            |/    \|               \|/__\
%
%   [ TRout ] = TriKeepLargestPatch( TRin )
%
% Inputs:
%   Tr - A triangulation object, composed of one or more connected patches.
%
% Outputs:
%   TRout - The largest connected patch from the patch(es) of Tr
%
% See also TRIDILATEMESH, TRIERODEMESH
% ------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ TRout ] = TriKeepLargestPatch( TRin )

    % Erode to break single vertex connections 
    Trin2 = TriErodeMesh(TRin, 1);
    % Find boundaries of all connected patches 
    Segments = Trin2.freeBoundary;
    % Construct close curves from the connected patch boundaries
    j = 1;
    Curves = struct();
    i = 1;
    while ~isempty(Segments)
        Curves(i).NodesID = zeros(length(Segments), 1);
        Curves(i).NodesID(j) = Segments(1, 1);
        Curves(i).NodesID(j+1) = Segments(1, 2);
        Segments(1,:)=[];
        j = j+1;
        [Is, Js] = ind2sub(size(Segments), find(Segments(:) == Curves(i).NodesID(j)));
        Nk = Segments(Is,round(Js+2*(1.5-Js)));
        Segments(Is,:) = [];
        j = j+1;
        while ~isempty(Nk)
            Curves(i).NodesID(j) = Nk(1);
            [Is, Js] = ind2sub(size(Segments), find(Segments(:) == Curves(i).NodesID(j)));
            Nk = Segments(Is, round(Js+2*(1.5-Js))); % Convert 1 to 2 and 2 to 1
            Segments(Is,:) = [];
            j = j+1;
        end
        Curves(i).NodesID(Curves(i).NodesID==0) = []  ;
        Curves(i).NodesID;
        i = i+1;
    end

    SizePatch = zeros(length(Curves),1);
    Patchs = struct();
    % Get each connected patch total area
    for k = 1 : length(Curves)
        Patchs(k).TR = TriConnectedPatch(TRin, Trin2.Points(Curves(k).NodesID(:), :));
        % Dilate eroded patch to approximately recover initial shape
        Patchs(k).TR = TriDilateMesh(Trin, Patchs(k).TR, 1); 
        PatchProperties = TriMesh2DProperties(Patchs(k).TR);
        SizePatch(k) = PatchProperties.TotalArea;
    end
    % Select largest connected patch for output
    [~,IMax] = max(SizePatch);
    TRout = Patchs(IMax).TR ;
end

