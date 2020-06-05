function [f, g0, g1, g2] = compSubexpression_Mit(w0, w1, w2)

% w0 = SingleVert(1);
% w1 = SingleVert(2);
% w2 = SingleVert(3);

temp0 = w0+w1;
temp1 = w0*w0;
temp2 = temp1+w1*temp0;

f(1) = temp0+w2;
f(2) = temp2+w2*f(1);
f(3) = w0*temp1+w1*temp2+w2*f(2);

g0 = f(2) + w0*(f(1)+w0);
g1 = f(2) + w1*(f(1)+w1);
g2 = f(2) + w2*(f(1)+w2);