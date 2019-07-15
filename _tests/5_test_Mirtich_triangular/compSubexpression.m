function [f1, f2, f3, g0, g1, g2] = compSubexpression(SingleVert)

w0 = SingleVert(1);
w1 = SingleVert(2);
w2 = SingleVert(3);

temp0 = w0+w1;
temp1 = w0*w0;
temp2 = temp1+w1*temp0;

f1 = temp0+w2;
f2 = temp2+w2*f1;
f3 = w0*temp1+w1*temp2+w2*f2;

g0 = f2 + w0*(f1+w0);
g1 = f2 + w1*(f1+w1);
g2 = f2 + w2*(f1+w2);

end