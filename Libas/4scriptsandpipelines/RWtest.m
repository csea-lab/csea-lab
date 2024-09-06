
for fileindex = 1:size(filemat,1)
    
    %load each person's data
        a = load(filemat(fileindex,:));
        contingencies = a(:,3);
        ratings = a(:,4);
        
%         contingencies = contingencies(1:end-1);
%         ratings = ratings(2:end);
%  
        model = 1; % the orig RW model 
opts = statset('nlinfit');
opts.RobustWgtFun = 'welsch'; % the robust settings on't have an impact

        [BETA(fileindex,:),R,J,COVB,MSE(fileindex,model),ErrorModelInfo] = nlinfit(contingencies,ratings./max(ratings),@rescorlaWagnerLearnOrig, [0.5],opts);
%changing starting value did nothing

        temp = rescorlaWagnerLearnOrig([BETA(fileindex,:)], contingencies);
        RSS = sum(R.^2);
                
        corrtemp = corrcoef(temp, ratings./max(ratings)); 
        corrmat(fileindex,model) = corrtemp(1,2);

        [ypred(fileindex,:),delta(fileindex,:)] = nlpredci(@rescorlaWagnerLearnOrig,(mean(temp)),BETA(fileindex,:),R,'Jacobian',J);

%        figure(5), plot(temp), hold on, plot(ratings./max(ratings))
%         title(fileindex, corrmat(fileindex))
%         pause
%         hold off
end

figure(5), bar(corrmat(:,1),1)
title('Subjective expectancy RW model fitting Robust (welsch)')
hold on, bar(BETA,1,'FaceAlpha',.7)
legend('Correlations','Learning rates')
