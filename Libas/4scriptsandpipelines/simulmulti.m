%simulmultiverse

A = randn(1,38) - .46; 
B = randn(1,18)- .35; 
C = randn(1,41)- .45; 
D = randn(1,36)- .45; 

[countsA, binA] = hist(A,20); 
[countsB, binB] = hist(B,20); 
[countsC, binC] = hist(C,20); 
[countsD, binD] = hist(D,20); 

%bins = -3:0.2:0.8; 

subplot(4,1,1), plot(A(A<0), rand(size(A(A<0)))+.5, 'ok', 'MarkerFaceColor', 'g', 'MarkerSize',14), axis([-3.2 3 0 2]), hold on
subplot(4,1,1), plot(A(A>0)./2, rand(size(A(A>0)))+.5, 'ok', 'MarkerFaceColor', 'r','MarkerSize',14), axis([-3.2 3 0 2]), hold off

subplot(4,1,2), plot(B(B<0), rand(size(B(B<0)))+.5, 'ok', 'MarkerFaceColor', 'g', 'MarkerSize',14), axis([-3.2 3 0 2]), hold on
subplot(4,1,2), plot(B(B>0)./1, rand(size(B(B>0)))+.5, 'ok', 'MarkerFaceColor', 'r','MarkerSize',14), axis([-3.2 3 0 3]), hold off

subplot(4,1,3), plot(C(C<0), rand(size(C(C<0)))+.5, 'ok', 'MarkerFaceColor', 'g', 'MarkerSize',14), axis([-3.2 3 0 2]), hold on
subplot(4,1,3), plot(C(C>0)./1, rand(size(C(C>0)))+.5, 'ok', 'MarkerFaceColor', 'r','MarkerSize',14), axis([-3.2 3 0 2]), hold off

subplot(4,1,4), plot(D(D<0), rand(size(D(D<0)))+.5, 'ok', 'MarkerFaceColor', 'g','MarkerSize',14), axis([-3.2 3 0 2]), hold on
subplot(4,1,4), plot(D(D>0)./1, rand(size(D(D>0)))+.5, 'ok', 'MarkerFaceColor', 'r','MarkerSize',14), axis([-3.2 3 0 2]), hold off

%%
subplot(2,2,1), plot(statmat(:, 8),statmat(:, 1), 'ok', 'MarkerFaceColor', 'y', 'MarkerSize',14), lsline, 
subplot(2,2,2), plot(statmat(:, 1),statmat(:, 5), 'ok', 'MarkerFaceColor', 'k', 'MarkerSize',14), lsline, 
subplot(2,2,3), plot(statmat(:, 8),statmat(:, 5), 'ok', 'MarkerFaceColor', 'y', 'MarkerSize',14), lsline, 
subplot(2,2,4), plot(statmat(:, 2),statmat(:, 7), 'ok', 'MarkerFaceColor', 'y', 'MarkerSize',14), lsline, 
