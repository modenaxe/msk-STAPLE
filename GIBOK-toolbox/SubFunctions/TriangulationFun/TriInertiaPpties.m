function [eigVctrs, CenterVol, InertiaMatrix, D ] = TriInertiaPpties( Tr )
%Get inertia of polyhedra of triangular faces

if ~isempty(Tr.freeBoundary)
    errLine1 = 'The inertia properties are for hole-free triangulations.';
    errLine2 = ' Close your mesh before use, try with TriFillPlanarHoles.';
    errLine3 = ' For 2D mesh use TriMesh2DProperties.';
    error(strcat(errLine1,errLine2,errLine3))
end

PseudoCenter = mean(Tr.Points);
Nodes = bsxfun(@minus,Tr.Points,PseudoCenter);

Elmts = Tr.ConnectivityList;

InertiaMatrix = zeros(3);

mult = [1/6 ;1/24 ;1/24 ;1/24 ;1/60 ;1/60 ;1/60 ;1/120 ;1/120 ;1/120];
intg = zeros(10,1);


for trian=1:length(Elmts)
    % vertices of elements #trian
    P1 = Nodes(Elmts(trian,1),:);
    P2 = Nodes(Elmts(trian,2),:);
    P3 = Nodes(Elmts(trian,3),:);
    % Get cross product
    CP = cross(P2-P1,P3-P1);
    d0 = CP(1); d1 = CP(2); d2 = CP(3);
    
    % 
    [x0 , x1 , x2 , f1x , f2x , f3x , g0x , g1x , g2x] = Subexpressions ( P1(1) , P2(1) , P3(1));
    [y0 , y1 , y2 , f1y, f2y , f3y , g0y , g1y , g2y] = Subexpressions ( P1(2) , P2(2) , P3(2));
    [z0 , z1 , z2 , f1z, f2z , f3z , g0z , g1z , g2z] = Subexpressions ( P1(3) , P2(3) , P3(3));
    
    % Update integrals
    intg(1) = intg(1) + d0*f1x;

    intg(2) = intg(2) + d0*f2x;
    intg(5) = intg(5) + d0*f3x;
    
    intg(3) = intg(3) + d1*f2y;
    intg(6) = intg(6) + d1*f3y;
    
    intg(4) = intg(4) + d2*f2z;
    intg(7) = intg(7) + d2*f3z;
    
    intg(8) = intg(8) + d0*(y0*g0x + y1*g1x + y2*g2x);
    intg(9) = intg(9) + d1*(z0*g0y + z1*g1y + z2*g2y);
    intg(10) = intg(10) + d2*(x0*g0z + x1*g1z + x2*g2z);
    
end

intg = intg.*mult;

for i=1:10
    
    
   
mass = intg(1) ;

CenterVol = [ intg(2)/mass; intg(3)/mass; intg(4)/mass ];


InertiaMatrix(1,1) = intg(6) + intg(7) - mass*(CenterVol([2 3])'*CenterVol([2 3]));
InertiaMatrix(2,2) = intg(5) + intg(7) - mass*(CenterVol([3 1])'*CenterVol([3 1]));
InertiaMatrix(3,3) = intg(5) + intg(6) - mass*(CenterVol([1 2])'*CenterVol([1 2]));


InertiaMatrix(1,2) =  - (intg(8) - mass*CenterVol(1)*CenterVol(2));
InertiaMatrix(2,3) =  - (intg(9) - mass*CenterVol(2)*CenterVol(3));
InertiaMatrix(3,1) =  - (intg(10) - mass*CenterVol(3)*CenterVol(1));

InertiaMatrix(2,1) = InertiaMatrix(1,2);
InertiaMatrix(3,2) = InertiaMatrix(2,3);
InertiaMatrix(1,3) = InertiaMatrix(3,1);



CenterVol = CenterVol + PseudoCenter';


[eigVctrs,D] = eig(InertiaMatrix);
end

