function [f, g] = compSubexpression_LM(oneV)

w0 = oneV(1);
w1 = oneV(2);
w2 = oneV(3);

temp0 = w0+w1;
temp1 = w0*w0;
temp2 = temp1+w1*temp0;

f(1) = temp0+w2;
f(2) = temp2+w2*f(1);
f(3) = w0*temp1+w1*temp2+w2*f(2);

g = f(2) + oneV .* (f(1) + oneV);
