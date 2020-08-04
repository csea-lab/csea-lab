function [convec] = bop2conrafa(datfilepath); 

mat = load(datfilepath); 

y = quantile(mat(:,4), [0.33333333 0.66666666]); 

convec = zeros(size(mat,1),1); 
convec(mat(:,4) <= y(1))=1;
convec(mat(:,4) >= y(2))=2;

end



