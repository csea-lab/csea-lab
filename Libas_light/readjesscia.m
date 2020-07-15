fid = fopen('204-1_Artifact RejectionUnpleasant.dat'); 

b = fread(fid, [64, 900*112] , 'float32');

c = reshape(b, [64, 900, 112]);

[WaPower, PLI, PLIdiff] = wavelet_app_mat(c, 500, 10, 100, 2, [], 'test');
test = bslcorrWAMat_div(WaPower, [200:300]);
contourf(squeeze(test(35,100:800, :))')