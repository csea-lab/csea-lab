% a = [0.01
% 0.84
% 0.06
% 0.036
% 0.001]
a = p_fMRI

hist(a)
hm = length(a(a<0.05))

ODR = hm/length(a)

histogram(a,[0.000001 0.01 0.02 0.03 0.04 0.05 1])
b = norminv(a)
b = norminv(a./2)
hist(b)
histogram(a,[0.000001 0.01 0.02 0.03 0.04 0.05 1])
hist(b)
b = norminv(1-a./2)
hist(b)
b = norminv(1-a./2)
hist(b, 20)
xline(1.96)
xline(1.96, 'r')
b = norminv(1-a)
b = norminv(1-a./2)
b = norminv(1-a)
hist(b, 20)
xline(1.96, 'r')
b = norminv(1-a./2)
hist(b, 20)
xline(1.96, 'r')
figure, hist(a(a< 0.051), 20)
figure, hist(a(a< 0.051), 10)
figure, hist(a(a< 0.051), 12)
figure, hist(a(a< 0.051), 5)
figure, hist(a(a< 0.051), [0.01 0.02 0.03 0.04 0.05])
figure, hist(a(a< 0.051), [0.005 0.015 0.025 0.035 0.045])
b = norminv(1-a./2)
hist(b, 20)
xline(1.96, 'r')
