function [out] = group_STamp(filemat, Nbins)

Nbins = Nbins+1
for fileindex = 1:size(filemat,1), 
    
    a = readavgfile(deblank(filemat(fileindex,:))); 
  size(a,2)
   shift = floor(size(a,2)/Nbins)
   
   outmat = zeros(size(a,1), Nbins-1);
    
count = 1;

if size(a,2) > Nbins+shift

        for index = 1 : shift : Nbins * shift-shift

            outmat(:, count) = mean(a(:, index:index+shift), 2);
            count = count+1;

        end

else
   outmat(:, 1:min(size(a,2),5)) = a(:, 1:min(size(a,2),5)); 
    
end

% 
% outmat
% count
% shift
%   size(a,2)
% index
% size(outmat),

 SaveAvgFile([deblank(filemat(fileindex,:)) num2str(Nbins-1) ],outmat,[],[],1,[],[],[])
    
end
