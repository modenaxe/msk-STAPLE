%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
function ProxTibNoFib = removeFibulaFromProxTibia(ProxTib, funcNameForWarning)
% remove fibula
% it is assumed that fibula will appear as an individual triangulation,
% e.g. it was segmented individually and then added as a mesh layer to
% tibia
[TrSplitted] = TriSplitObjects(ProxTib);
if max(size(TrSplitted))==2
    if TrSplitted(1).Vol>TrSplitted(2).Vol
        ProxTibNoFib = TrSplitted(1).Tr;
    else
        ProxTibNoFib = TrSplitted(2).Tr;
    end
elseif max(size(TrSplitted))>2
    warndlg({['Proximal Tibia in ',funcNameForWarning,' consists of >2 triangulations. Please check!'],...
        'Proceeding with current geometry...'});
    ProxTibNoFib = ProxTib;
end
end