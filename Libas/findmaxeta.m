function [ maxetavec, wmat ] = findmaxeta( datamat, u, r , CStypeindex)
% findmaxeta runs rescorla wagner mode for different etas on matrix datamat
% outputs best-fitting weights and maximum etas (learning parameter) 
% cstypeindex detremines if weights for CS+ (1) or CS- (2)  wil be used. 

etavector = 0.2:.02:0.99; 

for subject = 1:size(datamat,1); 
    
    counter = 1
    
    for eta = 0.2:.02:0.99; 
         w = rescorlaWagnerModelAK(u, r, eta);     
         temp = corrcoef(w(:,CStypeindex),datamat(subject, :)); 
         Rsquarevec(counter) = temp(1,2).^2; 
         counter = counter+1;
    end
    
    figure(10), hold on , plot(Rsquarevec, 'r'), pause, plot(Rsquarevec, 'b')
    
    [dummy, maxetaindex] = (max(Rsquarevec)), pause
    
    maxetavec(subject) = etavector(maxetaindex); 
  
    wmattemp = rescorlaWagnerModelAK(u, r, etavector(maxetaindex)); 
    
    wmat(subject,:) = wmattemp(:, CStypeindex);
    
    
    
end
    
    



