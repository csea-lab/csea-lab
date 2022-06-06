
%% 

labelvectorfull = [ones(1200,1)*4;  ones(1200,1)*5];

channels = 1:129; 

mat3d4avg = alltrialsbothcondition(:, 1:1200);

mat3d5avg = alltrialsbothcondition(:, 1201:2400); 

Y = labelvectorfull'; 


trainmatfull1 = z_norm([squeeze((mat3d4avg(channels, : )))'; squeeze((mat3d5avg(channels, :)))']); % 1st dim are channels  
         

obj = fitclinear(trainmatfull1',labelvectorfull, 'Kfold',20, 'Solver','sparsa', 'ObservationsIn','columns');     
         
Yhat = kfoldPredict(obj); 

aha = confusionmat(Y,Yhat);

meanaccuracy = sum(diag(aha))./(sum(sum(aha)));
         

         