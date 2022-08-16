function test_kuiper()
%
% Uses Examples 4.2 from Fisher (1993) to test the kuiper.m function.


% Data from Appendix B.5
data = [
	1 1 2 2 3 8 9 12 16 17 ...
	19 23 28 28 34 34 35 36 36 37 ...
	41 45 49 50 51 53 58 68 69 70 ...
	72 72 76 78 80 85 97 97 99 101 ...
	105 121 125 126 133 141 143 149 152 156 ...
	160 163 167 168 170 171 172 174 175 176 ...
]'/180*pi;

% convert from axial to vector
data =  mod(2*data, 2*pi);

% unsort values, just to be safe
data = [rand(length(data),1) data(:)];
data = sortrows(data,1);
data = data(:,2);

[p, V, Dp, Dn] = kuiper( data );
fprintf('p = %.2f, expected <= 0.15\n', p);
fprintf('V = %.3f, expected = 1.586\n', V);
fprintf('Dp = %.4f, expected = 0.1389\n', Dp);
fprintf('Dn = %.4f, expected = 0.0611\n', Dn);
