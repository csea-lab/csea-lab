function [mexhat] = mexgenfit(spreadval, height, N )
%
a = gausswin(N,spreadval + height)';
b = gausswin(N,spreadval)';


% take a min b, z-transform the result
mexhat = z_norm((a./max(a) - b./(max(b)))+1);

%plot(mexhat)

