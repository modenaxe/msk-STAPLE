% SLICEFEMORAL2CONDYLES Slice femoral condyles for use in Kai2014_femur.
% This function is practically identical to 
% Kai2014_femur_fitSpheres2Condyles and it is used in one of the sanity
% checks in a recursive manner.
%
%   CS = sliceFemoralCondyles(DistFemTri, CS, debug_plots)
%
% Inputs:
%   DistFemTri - MATLAB Triangulation object for the distal femur (most 
%       distal third of the bone geometry, normally).
%
%   CS - structure including the reference systems and parameters
%       resulting from the geometrical analysis of the femur. In input it
%       requires a preliminary reference system defined as follow:
%           X0: ant-posterior direction, pointing posteriorly
%           Y0: medio-lateral direction, pointing medially
%           Z0: prox-distal direction, pointing cranially
%       These fields are initialised by Kai2014_femur_fitSphere2FemHead.
%
%   debug_plots - enable plots used in debugging. Value: 1 or 0 (default).
%
% Outputs:
%   CS - update input structure including radii and centres of the spheres
%       fitted to the femoral condyles identified by the algorithm.
%
%   FC_Med_Pts - points identified to belong to the medial femoral condyle.
%
%   FC_Lat_Pts - points identified to belong to the lateral femoral condyle.
%
% See also KAI2014_FEMUR_FITSPHERES2CONDYLES, KAI2014_FEMUR, 
% KAI2014_FEMUR_FITSPHERE2FEMHEAD.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese, loosely based on GIBOK prototype. 
%  Copyright 2020 Luca Modenese & Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [CS, FC_Med_Pts, FC_Lat_Pts] = sliceFemoralCondyles(DistFemTri, CS, debug_plots, debug_prints)

if nargin<4; debug_prints=0; end

% X0 points backwards in GIBOK
X0 = CS.X0;
Z0 = CS.Z0;

area_limit = 4;%mm^2
sections_limit = 15;

% most posterior point
[~ , I_Post_FC] = max( DistFemTri.Points*-X0 );
MostPostPoint = DistFemTri.Points(I_Post_FC,:);

FC_Med_Pts = [];
FC_Lat_Pts = [];
d = MostPostPoint*-X0 - 0.25;
count = 1;

% debug plots
if debug_plots == 1
    quickPlotTriang(DistFemTri, [], 1);
    plot3(MostPostPoint(:,1), MostPostPoint(:,2), MostPostPoint(:,3),'g*', 'LineWidth', 3.0);
end

keep_slicing = 1;
disp('Slicing femoral condyles...');
while keep_slicing

    [ Curves , ~, ~ ] = TriPlanIntersect(DistFemTri, X0 , d );
    Nbr_of_curves = length(Curves);
    
    % counting slices
    if debug_prints
        disp(['section #',num2str(count),': ', num2str(Nbr_of_curves),' curves.'])
    end
    count = count+1;
    
    % check if the curves touch the bounding box of DistFem
    for cn = 1:Nbr_of_curves
        if abs(max(Curves(cn).Pts * Z0)-max(DistFemTri.Points * Z0)) < 8 %mm
            disp('The plane sections are as high as the distal femur.')
            disp('The condyle slicing is happening in the incorrect direction of the anterior-posterior axis.')
            disp('Inverting axis.')
            CS.X0 = -CS.X0;
            [CS, FC_Med_Pts, FC_Lat_Pts] = sliceFemoralCondyles(DistFemTri, CS, debug_plots);
            return
        end
    end
    
    % stop if just one curve is found after there has been a second profile
    if Nbr_of_curves == 1 && ~isempty(FC_Lat_Pts)        
        return
    else
        % next slicing plane moved by 1 mm
        d = d - 1;
    end
    
    % if there are too many curves maybe you are slicing from the
    % front (happened) -> invert and restart
    if Nbr_of_curves > 2
        disp('The quality of the mesh is low ( > 3 section areas detected).');
        disp('Skipping section')
        continue
    end    
    
    % otherwise store slices
    if Nbr_of_curves == 1
        % always for 1 curves
        FC_Med_Pts = [FC_Med_Pts; Curves.Pts];
        
    elseif Nbr_of_curves == 2
        % first check the size of the areas. If too small it might be
        % spurious
        if size(Curves(2).Pts,1)<sections_limit
            disp('Slice recognized as artefact (few points). Skipping it.')
            continue
        end
        % section leading to very small areas are also removed.
        % this condition is rarely reached
        [ ~, Area_sec2 ] = PlanPolygonCentroid3D( Curves(2).Pts );
        if abs(Area_sec2)<area_limit
            disp('Slice recognized as artefact (small area). Skipping it.')
            continue
        end
        % needs to identify which is the section near starting point
        % using distance from centroid for that
        Centroid = [];
        Dist2MostPostPoint = [];
        for cn = 1:Nbr_of_curves
            Centroid(cn,:) = mean(Curves(cn).Pts);
            Dist2MostPostPoint(cn) = norm(MostPostPoint-Centroid(cn,:));
        end
        % closest curve to Dist2MostPostPoint is the one that started as
        % single curve
        [~,IcurvePost1] = min(Dist2MostPostPoint);
        % store data accordingly
        FC_Med_Pts = [FC_Med_Pts; Curves(IcurvePost1).Pts];
        FC_Lat_Pts = [FC_Lat_Pts; Curves(3-IcurvePost1).Pts];
    end
    
    % plot curves after break condition!
    if debug_plots == 1
        c_set = ['r', 'b','k'];
        if ~isempty(Curves)
            for c = 1:Nbr_of_curves
                if c>3; col = 'k'; else;  col = c_set(c);  end
                plot3(Curves(c).Pts(:,1), Curves(c).Pts(:,2), Curves(c).Pts(:,3), col); hold on; axis equal
            end
        end
    end
    
end

end