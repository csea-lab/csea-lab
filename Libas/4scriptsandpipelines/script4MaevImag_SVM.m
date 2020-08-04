
%%
% input are 11 regions for now

 meanaccuracy = []; 
 erroraccuracy = []; 

channels =  [1:11];

for person = 1:21
    
    a = load(filemat(person,:)); 
    boldstd = a.bold39; 
    boldpers = a.bold18; 
    alphastd = a.alpha39;
    alphapers = a.alpha18;
    alphastd = squeeze(mean(alphastd([7 8 19 31], :, :))); 
    alphapers = squeeze(mean(alphapers([7 8 19 31], :, :))); 
        
 labelvectorfull = [ones(size(boldstd,1),1).*1;  ones(size(boldpers,1),1).*2];
 
 Y = labelvectorfull; 

 timepointindex = 2; 

for timepoint = 1:8
    
       % matboth = [[squeeze(boldstd(:, timepointindex,:)) alphastd]; [squeeze(boldpers(:, timepointindex,:)) alphapers] ];
       matboth = [[squeeze(boldstd(:, timepointindex,:))]; [squeeze(boldpers(:, timepointindex,:))] ]; 

         trainmatfull = z_norm(matboth); % 2nd dim are regions  
         
        objforweights = fitcsvm(trainmatfull, labelvectorfull); 
         
         %objforweights = fitclinear(trainmatfull(:,:)',labelvectorfull, 'Solver','dual', 'ObservationsIn','columns');    
         
         Weight_topo = objforweights.Beta;     
        
         Ynoise =  labelvectorfull(randperm(length(labelvectorfull)));      
         
         obj = fitcsvm(trainmatfull,labelvectorfull, 'Kfold',10, 'Solver','ISDA', 'Prior', 'empirical');         
           
         Yhat = kfoldPredict(obj);
  
         aha = confusionmat(Y,Yhat); 
         
         ahanoise = confusionmat(Ynoise,Yhat); 
        
         meanaccuracy(person, timepoint)= sum(diag(aha))./(sum(sum(aha))); 
     
         erroraccuracy(person, timepoint)=  sum(diag(ahanoise))./(sum(sum(ahanoise))); % error for error bars. the eror stats needs more iterations

    fprintf('.'); 
    
    timepointindex = timepointindex+1; 

    if timepoint/50 == round(timepoint/50), disp(num2str(timepoint)), end

end % timepoint
% 
%  meanaccuracy(freq,:) = movingavg_as(meanaccuracy(freq,:), 14); 
%  erroraccuracy(freq,:) = movingavg_as(abs(erroraccuracy(freq,:)-0.5),14);
% 
plot(meanaccuracy(person,:)), hold on, pause(1)
% pause(.5)
% figure
% shadedErrorBar(1:9, meanaccuracy, erroraccuracy)
% pause(.5)

end % frequencies
% figure
% contourf(taxis, faxis, meanaccuracy), colorbar






