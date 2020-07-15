%Reynolds & Desimone Model
%Attentional selection

function [y12Out] = reynovarleft(t, bias, weight, X11) 

% strength of excitatory weight from input j
w12p1 = weight;
w12p2 = .2;
% activation of node j in the input region 
y11 = bias;
y12 = 1;
% strength of attention-dependent signal directed at input j
x11 = X11;
x12 = 1;
%strength of inhibitory weight from input j
w12n1 = .2;
w12n2 = .2;

%total excitatory activation received by
%the total output node
y12exc = w12p1*y11*x11 + w12p2*y12*x12;

%total inhibitory activation received by
%the total output node
y12inh = w12n1*y11*x11 + w12n2*y12*x12;


y12t = [];
y12t = [y12t 0];
inp = [];
h= 1;
for j = 1:(t/4)
    inp = [inp 0];
end
for j = (t/4):(t/2)
    inp = [inp y12exc];
end
for j = (t/2):((3*t)/4)
    inp = [inp 0];
end
for j = ((3*t)/4): t
    inp = [inp y12exc];
end

if(t>0)
    for i= 1:t
        y12t = [y12t (y12t(i-1+1) + .1*((1-y12t(i-1+1))*inp(h) -(.2+y12inh)*y12t(i-1+1)))];
        h = h +1;
    end
    y12Out = y12t;

else
    y12Out = 0;
end






