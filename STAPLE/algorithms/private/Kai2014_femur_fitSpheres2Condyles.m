% KAI2014_FEMUR_FITSPHERES2CONDYLES Slice the distal part of the femoral
% geometries using planes perpendicular to the anterio-posterior direction.
% It starts from the most posterior point of the condyles, that is normally
% on the medial condyle. This point, and the geometrical operations, are
% performed relying on the reference system X0-Y0-Z0 defined in 
% Kai2014_femur_fitSphere2FemHead.m, which has proved reliable in our
% tests. 
% The function assumes that the first slice(s) will only produce one
% slicing area (cutting just the medial condyle), then two slicing areas
% (cutting plane reaching also lateral condyles) and when the slicing
% profile is again a single area the function will stop, assuming the
% entire condyles have been slices. At that point each condyles will be
% fit using a spherical least-squares fit.
% Despite the simplicity of the algorithm, several things can go wrong,
% especially if a low-quality mesh is being processed, so there are
% multiple checks for ensuring that the cuts are being performed in the
% correct directions and according to the algorithm.
%
%   CS = Kai2014_femur_fitSpheres2Condyles(DistFemTri, CS, debug_plots)
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
% See also KAI2014_FEMUR, KAI2014_FEMUR_FITSPHERE2FEMHEAD.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese, loosely based on GIBOK prototype. 
%  Copyright 2020 Luca Modenese & Jean-Baptiste Renault
%-------------------------------------------------------------------------%

function CS = Kai2014_femur_fitSpheres2Condyles(DistFemTri, CS, debug_plots, debug_prints)

% main plots are in the main method function. 
% these debug plots are to see the details of the method
if nargin<3; debug_plots=0; end
if nargin<4; debug_prints=0; end
X0 = CS.X0;
Z0 = CS.Z0;

area_limit = 4;%mm^2
sections_limit = 15;
dist_area_centroid_threshold = 20; %mm
% X0 points backwards in GIBOK

% most posterior point
% NOTE: it assumes that the mostPosteriorPoint is MEDIAL, if that is not
% the case there will be a check at the end of the function.
[~ , I_Post_FC] = max( DistFemTri.Points*-X0 );
MostPostPoint = DistFemTri.Points(I_Post_FC,:);

FC_Med_Pts = [];
FC_Lat_Pts = [];
d = MostPostPoint*-X0 - 0.25;
count = 1;

% debug plot
if debug_plots == 1
    quickPlotTriang(DistFemTri, [], 1);
    plotDot(MostPostPoint,'g', 5.0);
end

keep_slicing = 1;

% print
disp('  Slicing femoral condyles...');

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
            break
        end
    end
    
    % stop if just one curve is found after there has been a second profile
    if Nbr_of_curves == 1 && ~isempty(FC_Lat_Pts)        
        break
    else
        % next slicing plane moved by 1 mm
        d = d - 1;
    end
    
    % if there are too many curves maybe you are slicing from the
    % front (happened) -> invert and restart
    if Nbr_of_curves > 2
        disp('The quality of the mesh is low (>3 section areas detected).');
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
        [ Centroid2, Area_sec2 ] = PlanPolygonCentroid3D( Curves(2).Pts );
        if abs(Area_sec2)<area_limit
            disp('Slice recognized as artefact (small area). Skipping it.')
            continue
        end
        % section might and up in the same condyle even
        [ Centroid1, ~ ] = PlanPolygonCentroid3D( Curves(1).Pts );
        if norm(Centroid1-Centroid2)< dist_area_centroid_threshold
            disp('Slice recognized as artefact (two areas on same condyle). Skipping it.')
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

disp(['  Sliced #', num2str(count), ' times']);

% fitting spheres to points from the sliced curves
[center_med,radius_med] = sphereFit(FC_Med_Pts);
[center_lat,radius_lat] = sphereFit(FC_Lat_Pts);

% centre of the knee if the midpoint between spheres
KneeCenter = 0.5*(center_med+center_lat);

% the Kai2014_femur_fitSphere2FemHead.m function does a good job at
% initialising the directions of the X0-Y0-Z0 reference system correctly,
% while this slicing function can identify medial and lateral condyles 
% incorrectly. This check verifies that the identification is correct,
% otherwise it switches the condyles.
med_v_to_check = (center_med - center_lat);
if sign(dot(CS.Y0, med_v_to_check))<0
    warning('Femur_Kai: Incorrect identification of medial and lateral condyles. Inverting M-L axis')
    center_lat_temp = center_med;
    radius_lat_temp = radius_med;
    center_med = center_lat;
    radius_med = radius_lat;
    center_lat = center_lat_temp;
    radius_lat = radius_lat_temp;
end

% store axes in structure
CS.Center_Lat = center_lat;
CS.Radius_Lat = radius_lat;
CS.Center_Med = center_med;
CS.Radius_Med = radius_med;
CS.KneeCenter = KneeCenter;

% plot spheres
if debug_plots == 1
    plotSphere(center_med, radius_med, 'r', 0.4);
    plotSphere(center_lat, radius_lat, 'b', 0.4);
end

% check sections
if debug_plots
    figure()
    plot3(FC_Med_Pts(:,1), FC_Med_Pts(:,2), FC_Med_Pts(:,3),'r.');
    hold on; axis equal
    plot3(FC_Lat_Pts(:,1), FC_Lat_Pts(:,2), FC_Lat_Pts(:,3),'b.');
    plotDot(MostPostPoint,'g', 2.0);
    title('check if slices are reasonable (red:medial')
end

% % print
% disp('Done with femoral condyles.')
% disp('----')

end