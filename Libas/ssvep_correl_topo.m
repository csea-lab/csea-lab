%ssvep_correl_topo
function [corrvec] = ssvep_correl_topo(filemat, arovec)

if size(filemat,1) ~= length(arovec), error('incorrect number of rating values') , end

probe = ReadAvgFile(deblank(filemat(1,:)));

% tic
% for sensor = 1:size(probe,1); 
%     disp(sensor)
% 	for x = 1 : size(filemat,1);
% 	a = ReadAvgFile(filemat(x,:));
%     sensvalues(x) = a(sensor);
% 	end
%     del = corrcoef(arovec, sensvalues);
%     corrvec(sensor) = del(2); 
% end
% toc

mat = []
tic

	for x = 1 : size(filemat,1);
	a = ReadAvgFile(deblank(filemat(x,:)));
    mat = [mat a(:,1)]; 
	end
    for sensor = 1:size(mat,1)
    del = corrcoef(mat(sensor,:), arovec);
    corrvec(sensor) = del(2); 
    end
toc