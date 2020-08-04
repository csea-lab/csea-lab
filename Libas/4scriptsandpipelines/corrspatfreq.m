
clear corrmat
clear corrmatPerm

[wavelet] = gener_wav(1322, 1, 30, 30);

for person = 1:50
    for condition = 1:20
        testal = squeeze(aMat(person,condition,80:end));
        testss = squeeze(ssmat(person,condition,80:end));       
        corrmat(person, condition) = corr(testal, testss, 'type', 'Kendall');        
    end
end

corrmat_fish = fisher_z(corrmat);
figure(11), plot(mean(corrmat_fish, 2));

% %%
% %permutation test 1: random new data
% for run = 1:100, fprintf('.')
%     for person = 1:50
%         for condition = 1:20
%             testal = abs(ifft(wavelet .* fft(rand(1,1322))));
%             testss = steadyHilbertMat(rand(1, 1322), 13.33, [], 10, 0, 500);
%             corrmatPerm(person, condition, run) = corr(testal', testss', 'type', 'Kendall');       
%         end
%     end
% end
% 
% histveccorr = (mat2vec(squeeze((corrmatPerm))));
% figure(12), hist(histveccorr, 100)
% 
% [bin,tval] = hist(histveccorr,500);
% critbin = sum(bin).*.95
% cumbins = cumsum(bin);
% indices = find(cumbins > critbin);
% index = min(indices);
% critTmaxCorr = tval(index)
% 
% 
% [bin,tval] = hist(histveccorr,500);
% critbin = sum(bin).*0.05
% cumbins = cumsum(bin);
% indices = find(cumbins < critbin);
% index = max(indices);
% critTminCorr = tval(index)

%%
%permutation test 2: shuffled data across people and conditions
for run = 1:100, fprintf('.')
    for person = 1:50
        for condition = 1:20
             testal = squeeze(aMat(randperm(50,1),randperm(20,1),80:end));
             testss = squeeze(ssmat(randperm(50,1),randperm(20,1),80:end));       
             corrmatPerm2(person, condition) = corr(testal, testss, 'type', 'Kendall');        
        end
    end
end

histveccorr2 = (mat2vec(squeeze((corrmatPerm2))));
figure(13), hist(histveccorr2, 100)

[bin,tval] = hist(histveccorr2,500);
critbin = sum(bin).*.95
cumbins = cumsum(bin);
indices = find(cumbins > critbin);
index = min(indices);
critTmaxCorr2 = tval(index)


[bin,tval] = hist(histveccorr2,500);
critbin = sum(bin).*0.05
cumbins = cumsum(bin);
indices = find(cumbins < critbin);
index = max(indices);
critTminCorr2= tval(index)

%%
% dot product approach 

for person = 1:50
    for condition = 1:20
           testal = z_norm(squeeze(aMat(person,condition,80:end)));
           testss = z_norm(squeeze(ssmat(person,condition,80:end)));       
          dotprodmat(person, condition) = (testal'*testss)./length(testal);      
    end
end

% %permutation test 1: random data
% for run = 1:100, fprintf('.')   
%     for person = 1:50
%         for condition = 1:20
%                testal = z_norm(steadyHilbertMat(rand(1, 1322), 8, [], 9, 0, 500));
%             testss = z_norm(steadyHilbertMat(rand(1, 1322), 13.33, [], 10, 0, 500));
%               dotprodmatPerm(person, condition,run) =(testal*testss')./length(testal);      
%         end
%     end
% end
% 
% 
% histvecdot = (mat2vec(squeeze((dotprodmatPerm))));
% figure(14), hist(histvecdot, 100)
% figure(16), bar(mean(dotprodmat, 2));
% 
% [bin,tval] = hist(histvecdot,500);
% critbin = sum(bin).*.95
% cumbins = cumsum(bin);
% indices = find(cumbins > critbin);
% index = min(indices);
% critTmaxDot = tval(index)
% 
% 
% [bin,tval] = hist(histvecdot,500);
% critbin = sum(bin).*0.05
% cumbins = cumsum(bin);
% indices = find(cumbins < critbin);
% index = max(indices);
% critTminDot = tval(index)


%%
%%%permutation test 2: permuted actual data 
for run = 1:100, fprintf('.')   
    for person = 1:50
        for condition = 1:20
                testal = squeeze(aMat(randperm(50,1),randperm(20,1),80:end));
               testss = squeeze(ssmat(randperm(50,1),randperm(20,1),80:end));       
              dotprodmatPerm2(person, condition,run) =(testal'*testss)./length(testal);      
        end
    end
end


histvecdot2 = (mat2vec(squeeze((dotprodmatPerm2))));
figure(15), hist(histvecdot2, 100)


[bin,tval] = hist(histvecdot2,500);
critbin = sum(bin).*.95
cumbins = cumsum(bin);
indices = find(cumbins > critbin);
index = min(indices);
critTmaxDot2 = tval(index)


[bin,tval] = hist(histvecdot2,500);
critbin = sum(bin).*0.05
cumbins = cumsum(bin);
indices = find(cumbins < critbin);
index = max(indices);
critTminDot2 = tval(index)
