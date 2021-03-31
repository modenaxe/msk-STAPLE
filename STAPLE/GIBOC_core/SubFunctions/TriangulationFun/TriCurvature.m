% TRICURVATURE Calculate the principal curvature directions and values
% of a triangulated mesh. 
%
% The function first rotates the data so the normal of the current
% vertex becomes [-1 0 0], so we can describe the data by XY instead of
% XYZ.
% Secondly it fits a least-squares quadratic patch to the local 
% neighborhood of a vertex "f(x,y) = ax^2 + by^2 + cxy + dx + ey + f". 
% Then the eigenvectors and eigenvalues of the hessian are used to
% calculate the principal, mean and gaussian curvature.
%
% [Cmean,Cgaussian,Dir1,Dir2,Lambda1,Lambda2]=patchcurvature(FV,usethird)
%
% inputs,
%   TR : A triangulation mesh object (see Patch)
%   usethird : Use third order neighbour vertices for the curvature
%              fit, making it smoother but less local. true/ false (default)
%
% outputs,
%   Cmean : Mean Curvature
%   Cgaussian : Gaussian Curvature
%   Dir1 : XYZ Direction of first Principal component
%   Dir2 : XYZ Direction of second Principal component
%   Lambda1 : value of first Principal component
%   Lambda2 : value of second Principal component
%
% Example, Jaw
%   load('testdata.mat');
%
%   [Cmean,Cgaussian,Dir1,Dir2,Lambda1,Lambda2]=patchcurvature(FV,true);
%
%   figure, title('Principal A');
%     p1=FV.vertices-2*Dir1; p2=FV.vertices+2*Dir1;       
%     plot3([p1(:,1) p2(:,1)]',[p1(:,2) p2(:,2)]',[p1(:,3) p2(:,3)]','g-');
%     axis equal; view(3) 
%   figure, title('Principal B');
%     p1=FV.vertices-2*Dir2; p2=FV.vertices+2*Dir2;       
%     plot3([p1(:,1) p2(:,1)]',[p1(:,2) p2(:,2)]',[p1(:,3) p2(:,3)]','r-');
%     axis equal; view(3)
%
%
% Example, Cylinder
%   load('testdata2.mat');
%
%   [Cmean,Cgaussian,Dir1,Dir2,Lambda1,Lambda2]=patchcurvature(FV);
%
%   figure,
%   subplot(2,2,1), title('Mean Curvature');
%     C=Cmean;
%     patch(FV,'FaceColor','interp','FaceVertexCData',C,'edgecolor','none');
%     axis equal; view(3)
%   subplot(2,2,2), title('Gaussian Curvature');
%     C=Cgaussian;
%     patch(FV,'FaceColor','interp','FaceVertexCData',C,'edgecolor','none');
%     axis equal; view(3)
%   subplot(2,2,3), title('Principal A');
%     p1=FV.vertices-2*Dir1; p2=FV.vertices+2*Dir1;       
%     plot3([p1(:,1) p2(:,1)]',[p1(:,2) p2(:,2)]',[p1(:,3) p2(:,3)]','g-');
%     axis equal; view(3) 
%   subplot(2,2,4), title('Principal B');
%     p1=FV.vertices-2*Dir2; p2=FV.vertices+2*Dir2;       
%     plot3([p1(:,1) p2(:,1)]',[p1(:,2) p2(:,2)]',[p1(:,3) p2(:,3)]','r-');
%     axis equal; view(3)
%     
%  Example Torus;
%   load('testdata3.mat');
%
%   [Cmean,Cgaussian,Dir1,Dir2,Lambda1,Lambda2]=patchcurvature(FV);
%
%   figure, 
%   hold on
%   V=FV.vertices;
%   plot3(V(Cgaussian<0,1),V(Cgaussian<0,2),V(Cgaussian<0,3),'r.');
%   plot3(V(Cgaussian>0,1),V(Cgaussian>0,2),V(Cgaussian>0,3),'b.');
%   axis equal; view(3)
% ------------------------------------------------------------------------%
% Function is written by D.Kroon University of Twente (August 2011)  
% Last Update, 15-1-2014 D.Kroon at Focal.
% ------------------------------------------------------------------------%
% Slightly modified for triangulation inputs
% Last modification, 15-11-2017; JB Renault at AMU.
% ------------------------------------------------------------------------%
function [Cmean,Cgaussian,Dir1,Dir2,Lambda1,Lambda2]=TriCurvature(TR,usethird, Rot0)

% Check inputs
if(nargin<2), usethird=false; end

if(nargin==3)
    % Change Triangulation position for conditioning:
    TR = triangulation(TR.ConnectivityList,TR.Points*Rot0);
end

% Number of vertices
nv = size(TR.Points,1);

% Calculate vertices normals
N = TR.vertexNormal;


% Calculate Rotation matrices for the normals
M= zeros(3,3,nv);
Minv= zeros(3,3,nv);
for i=1:nv 
    [M(:,:,i),Minv(:,:,i)]=VectorRotationMatrix(N(i,:));
end

% Get neighbours of all vertices
Ne=TR.vertexAttachments;

% Loop through all vertices
Lambda1=zeros(nv,1);
Lambda2=zeros(nv,1);
Dir1=zeros(nv,3);
Dir2=zeros(nv,3);

for i=1:nv
   % Get first and second ring neighbours.
   if(~usethird) 
       Nce = unique(NotNaN(TR([Ne{unique(NotNaN(TR(Ne{i},:)))}],:)));
       
   else
       % Get first, second and third ring neighbours
       Nce=unique(NotNaN(TR(unique(NotNaN(TR.neighbors(unique(NotNaN(TR.neighbors(Ne{i}')))))),:)));
   end
%    Nce
   Ve=TR.Points(Nce,:);

   % Rotate to make normal [-1 0 0]
   We=Ve*Minv(:,:,i);
   f=We(:,1); x=We(:,2); y=We(:,3); 
   
   % Fit patch
   % f(x,y) = ax^2 + by^2 + cxy + dx + ey + f
   FM=[x(:).^2 y(:).^2 x(:).*y(:) x(:) y(:) ones(numel(x),1)];
   abcdef=FM\f(:);
   a=abcdef(1); b=abcdef(2); c=abcdef(3);
   
   Dxx = 2*a; Dxy=c; Dyy=2*b;
   
   [Lambda1(i),Lambda2(i),I1,I2]=eig2(Dxx,Dxy,Dyy);
   
   dir1=[0 I1(1) I1(2)]*M(:,:,i);
   dir2=[0 I2(1) I2(2)]*M(:,:,i);
   Dir1(i,:)=dir1/sqrt(dir1(1)^2+dir1(2)^2+dir1(3)^2);
   Dir2(i,:)=dir2/sqrt(dir2(1)^2+dir2(2)^2+dir2(3)^2);
end
Cmean=(Lambda1+Lambda2)/2;
Cgaussian=Lambda1.*Lambda2;


function [Lambda1,Lambda2,I1,I2]=eig2(Dxx,Dxy,Dyy)
% | Dxx  Dxy |
% |          |
% | Dxy  Dyy |
%
% example,
%   Dxx=round(rand*10); Dxy=round(rand*10); Dyy=round(rand*10); 
%   [a,b,c,d]=eig2(Dxx,Dxy,Dyy)
%   D = [a 0;0 b];
%   V = [c(:) d(:)];
%   check =  sum(abs(M*V(:,1) - D(1,1)*V(:,1))) + sum(abs(M*V(:,2) - D(2,2)*V(:,2))) ;

% Compute the eigenvectors 
tmp = sqrt((Dxx - Dyy).^2 + 4*Dxy.^2);
v2x = 2*Dxy; v2y = Dyy - Dxx + tmp;

% Normalize
mag = sqrt(v2x.^2 + v2y.^2); i = (mag ~= 0);
v2x(i) = v2x(i)./mag(i);
v2y(i) = v2y(i)./mag(i);

% The eigenvectors are orthogonal
v1x = -v2y; v1y = v2x;

% Compute the eigenvalues
mu1 = (0.5*(Dxx + Dyy + tmp));
mu2 = (0.5*(Dxx + Dyy - tmp));

% Sort eigen values by absolute value abs(Lambda1)<abs(Lambda2)
if(abs(mu1)<abs(mu2))
    Lambda1=mu1;
    Lambda2=mu2;
    I2=[v1x v1y];
    I1=[v2x v2y];
else
    Lambda1=mu2;
    Lambda2=mu1;
    I2=[v2x v2y];
    I1=[v1x v1y];
end

function [Y] = NotNaN(X)
X=X(:);
% Keep only not NaN elements of a vector
Y = X(~isnan(X));
    

function [M,Minv]=VectorRotationMatrix(v)
% [M,Minv]=VectorRotationMatrix(v,k)
v=(v(:)')/sqrt(sum(v.^2));
k=rand(1,3);
l = [k(2).*v(3)-k(3).*v(2), k(3).*v(1)-k(1).*v(3), k(1).*v(2)-k(2).*v(1)]; l=l/sqrt(sum(l.^2));
k = [l(2).*v(3)-l(3).*v(2), l(3).*v(1)-l(1).*v(3), l(1).*v(2)-l(2).*v(1)]; k=k/sqrt(sum(k.^2));
Minv=[v(:) l(:) k(:)];

if cond(Minv) > 1000
    warning('Potential bad conditionning')
end

M=inv(Minv);




