
function [pred_mat,Betamat,corrmat] = modelfit_Pupil(pupilfilemat)
%latest version june 27
warning('off')
for fileindex = 1:size(pupilfilemat,1)
    
    data = load(pupilfilemat(fileindex,:), 'matcorr3d', 'exper');
    eye = data.matcorr3d;
    pupil = squeeze(eye(3,:,:));
    pupil2 = mean(pupil,1); % average over time   
    pupil3(:,:) = pupil2(:,:)./(max(pupil2(:,:)));
    
    contingencies = data.exper;

model = 1;
       [BETA,R,J,COVB,MSE] = nlinfit(contingencies,pupil3',@rescorlaWagnerLearnOrig, [0.5]);
        temp = rescorlaWagnerLearnOrig([BETA], contingencies);
        temp(1)= 0.5;

        RSS = sum(R.^2);
        
        Betamat(fileindex,model*2-1) = BETA(1); 
        
        corrtemp = corrcoef(temp, pupil3); 
        corrmat(fileindex, model) = corrtemp(2);
                
        pred_mat(model,fileindex,:) = temp;
        
model = 2;
       
       [BETA,R,J,COVB,MSE] = nlinfit(contingencies,pupil3',@gamblersf, [0.5]);
        temp = gamblersf([BETA], contingencies);
        temp(1)= 0.5;

        RSS = sum(R.^2);

        Betamat(fileindex,model*2-1) = BETA(1); 
        
        corrtemp = corrcoef(temp, pupil3); 
        corrmat(fileindex,model) = corrtemp(2);
   
        pred_mat(model,fileindex,:) = temp;
   
end %file loop
end %function 
