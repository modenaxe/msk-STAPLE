%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%    Author:   Luca Modenese                                              %
% ----------------------------------------------------------------------- %
function ProxTibNoFib = removeFibulaFromProxTibia(ProxTib, funcNameForWarning)
% remove fibula
% it is assumed that fibula will appear as an individual triangulation,
% e.g. it was segmented individually and then added as a mesh layer to
% tibia
disp('Attempting to remove fibula...')
[TrSplitted] = TriSplitObjects(ProxTib);
if max(size(TrSplitted))==2
    if TrSplitted(1).Vol>TrSplitted(2).Vol
        ProxTibNoFib = TrSplitted(1).Tr;
        % alternative
        %     ProxTibNoFib = TriReduceMesh(ProxTib, TrSplitted(1).elements)   ;
    else
        ProxTibNoFib = TrSplitted(2).Tr;
        % alternative
        % ProxTibNoFib = TriReduceMesh(ProxTib, TrSplitted(2).elements)  ;
    end
    disp('Fibula removed from triangulation.')
elseif max(size(TrSplitted))==1
    ProxTibNoFib = ProxTib;

elseif max(size(TrSplitted))>2
    warndlg({['Proximal Tibia in ',funcNameForWarning,' consists of >2 triangulations. Please check!'],...
        'Proceeding with current geometry...'});
    ProxTibNoFib = ProxTib;
end
end
