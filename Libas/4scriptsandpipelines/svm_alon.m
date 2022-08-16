
%% 

labelvectorfull = [ones(2463,1)*1;  ones(2463,1)*2];

channels = 1:27; 

mat3d3avg = power10Hz_3d(:, :, 1:2463);

mat3d6avg = power10Hz_3d(:, :, 2464:4926); 

Y = labelvectorfull'; 

  for timepoint = 1:size(mat3d3avg,2)

         trainmatfull1 = z_norm([squeeze((mat3d3avg(channels, timepoint, : )))'; squeeze((mat3d6avg(channels, timepoint, :)))']); % 1st dim are channels  
         obj = fitclinear(trainmatfull1(:,:)',labelvectorfull, 'Kfold',20, 'Solver','sparsa', 'ObservationsIn','columns');     
         Yhat = kfoldPredict(obj); 
         aha = confusionmat(Y,Yhat);
         meanaccuracy(timepoint) = sum(diag(aha))./(sum(sum(aha)));
         
         if timepoint/50 == round(timepoint/50); fprintf('.'), end
         
  end