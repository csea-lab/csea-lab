function [mexhat] = mexgenfit(spreadval, N )
%
a = gausswin(N,spreadval + 0.2)';
b = gausswin(N,spreadval)';


% take a min b, z-transform the result
mexhat = z_norm((a./max(a) - b./(max(b)))+1);

%plot(mexhat)

