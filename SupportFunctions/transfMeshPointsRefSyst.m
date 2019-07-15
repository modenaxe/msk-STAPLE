% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese, October 2015                                %
%    email:    l.modenese@sheffield.ac.uk                                 %
% ----------------------------------------------------------------------- %
% function that allows to transform a landmark cloud from the current
% reference system to the new reference system specified by newOrig and
% newAxesMat

function v_trasf = transfMeshPointsRefSyst(aVertexCloud, newOrig, newAxesMat)

% initializing
v = aVertexCloud;
orig = newOrig;
R = newAxesMat;

%======= APPLY TRANSFORMATION ======
% v_transf = Mat * (v - orig)
% chosen over an equivalent version with transposed because more efficient
% v_new2 = (R*(v-ones(size(v,1),1)*orig)')';
v_trasf = (v-ones(size(v,1),1)*orig)*R';

%======== FOR VISUAL CHECK ==========
% % plots meshes
% plot3(v(:,1),v(:,2),v(:,3),'b.'); hold on;axis equal;grid on
% plot3(v_trasf(:,1),v_trasf(:,2),v_trasf(:,3),'r.');
% % plot global axes
% scale = 300;
% plot_refsyst(gca, [0 0 0], eye(3), scale);
% plot3(orig(1),orig(2),orig(3),'MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor','g','Linewidth',2,'Color','k'), hold on
% % plot new axes and origin
% scale = 300;
% plot_refsyst(gca, orig, R, scale);
% %=====================================

end
