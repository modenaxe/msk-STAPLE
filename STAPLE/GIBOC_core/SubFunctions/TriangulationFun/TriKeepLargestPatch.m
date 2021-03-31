% TRIKEEPLARGESTPATCH Keep the largest (by area) connected patch of a 
% triangulation object.
% ------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ TRout ] = TriKeepLargestPatch( TRin )

Trin2 = TriErodeMesh(TRin,1);


Segments = Trin2.freeBoundary;



j=1;
Curves=struct();
i=1;
while ~isempty(Segments)
    Curves(i).NodesID = zeros(length(Segments),1);
    Curves(i).NodesID(j)=Segments(1,1);
    Curves(i).NodesID(j+1)=Segments(1,2);
    Segments(1,:)=[];
    j=j+1;
    [Is,Js] = ind2sub(size(Segments),find(Segments(:) == Curves(i).NodesID(j)));
    Nk = Segments(Is,round(Js+2*(1.5-Js)));
    Segments(Is,:)=[];
    j=j+1;
    while ~isempty(Nk)
%         Nk
        Curves(i).NodesID(j) = Nk(1);
        [Is,Js] = ind2sub(size(Segments),find(Segments(:) == Curves(i).NodesID(j)));
        Nk = Segments(Is,round(Js+2*(1.5-Js)));
        Segments(Is,:)=[];
        j=j+1;
    end
    Curves(i).NodesID(Curves(i).NodesID==0) = []  ;
    Curves(i).NodesID;
    i=i+1;
end



if length(Curves)>1
    
    SizePatch = zeros(length(Curves),1);
    Patchs = struct();
    for k = 1 : length(Curves)
        Patchs(k).TR = TriConnectedPatch(TRin,Trin2.Points(Curves(k).NodesID(:),:));
        [ Properties ] = TriMesh2DProperties( Patchs(k).TR );
        SizePatch(k) = Properties.TotalArea;
        
    end
    [~,IMax] = max(SizePatch);
    TRout = Patchs(IMax).TR ;
    
else
    TRout = TriDilateMesh(TRin,Trin2,1);
    
end



end

