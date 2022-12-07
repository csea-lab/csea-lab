function [BF] = BFttest_perm(vector1, vector2) 
% does bootstrapping based BF analysis equivalent to a ttest

warning('off')

 for draw = 1:5000
      subjects1 = randi(length(vector1),1,length(vector1));
      subjects2 = randi(length(vector2),1,length(vector2));
      boots(draw) = mean(vector1(subjects1))-mean(vector2(subjects2));    
 end
 
 if draw/100 == round(draw./100), fprintf('.'), end


warning('on')


posteriorsignedOdds = sum(find(boots < 0)) ./ draw;
    

BF = posteriorsignedOdds ./(1-posteriorsignedOdds);
