% TRISPLITOBJECTS splits triangulation composed of multiple unconnected
% parts.
%
% Input:
%   TrIn        A triangulation object containing multiple unconnected
%               parts
% Output:
%
%   TrSplitted: A structure containing the splitted parts of Tr
%               TrSplitted(i).Tr each separated Triangulation object
%               TrSplitted(i).Vol the volume of the Triangulation object
%
% -------------------------------------------------------------------------
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%--------------------------------------------------------------------------

function [TrSplitted] = TriSplitObjects(TrIn)

%% Part for developmment
% clear all
% close all
% load('C:\Users\jbapt\Documents\Research\auto-msk-model\test_geometries\LHDL_CT\tri\calcn_r.mat');
% TrIn = triang_geom;

%%
TrSplitted = struct();

ElementsID = 1:size(TrIn.ConnectivityList, 1);
Neigbours = TrIn.neighbors;

% Elements is list of elements Index that will be used to tell which
% elements has been processed (attributed to an object) or not
Elements = ElementsID;

%% Deal with bad mesh (flat parts)
Binary_notGood = Neigbours(:,1) == Neigbours(:,2) |...
    Neigbours(:,2) == Neigbours(:,3) |...
    Neigbours(:,3) == Neigbours(:,1);

% Set not good elements to -1
Elements(Binary_notGood) = -1;
    

%% Identify recursively the neighbours of a starting elements
% Once no new can be 
i = 1;
Idx_elmts_not_processed = find(Elements>0);
while ~isempty(Idx_elmts_not_processed)
    
    Istart = Idx_elmts_not_processed(1);
    Element_Start = Elements(Istart);
    
    % Initialise
    ElementListSize = 0;
    Elmts_prev = Element_Start;
    Elmts_curr = Element_Start;
    
    % Loop until no new neighbours are found meaning all the elements of
    % the current objects were identified
    while ElementListSize ~= length(Elmts_curr)
        ElementListSize = length(Elmts_curr);
        Elmts_new = NotNaN(Neigbours(Elmts_prev,:));
        Elmts_curr = unique([Elmts_prev; Elmts_new]);
        Elmts_prev = unique(Elmts_new);
    end
    
    % Add the elements to the current object
    TrSplitted(i).elements = Elmts_curr;
    
    % Set processed elements to -1
    Elements(Elmts_curr) = -1;
    
    % Find the potential next starting elements
    Idx_elmts_not_processed = find(Elements>0);
    
    i = i+1;
end

if i == 2
   warning("Only one part found check that the object is in several parts") 
end

%% Construct the triangulation object of each identified object
for i = 1:length(TrSplitted)
    Kold2new = [];
    K = TrIn.ConnectivityList(TrSplitted(i).elements,:);
    Kold2new(sort(unique(K(:)))) = 1:length(sort(unique(K(:))));
    TrSplitted(i).Pts = TrIn.Points(sort(unique(K(:))),:);
    TrSplitted(i).Tr = triangulation(Kold2new(K), TrSplitted(i).Pts);
    [~,~,~,~, TrSplitted(i).Vol] = TriInertiaPpties( TrSplitted(i).Tr );
    VolumeList(i) = TrSplitted(i).Vol;
end

%% Sort Output by volume
[~, is] = sort(VolumeList, 'descend');
TrSplitted = TrSplitted(is);


% 
% end

