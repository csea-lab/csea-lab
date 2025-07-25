%% bayesoanbootstrap fpr Laura's natsounds 

model = [1 -2 1]; 

for draw = 1:5000

   distributionquad(draw) = mean(combine_mat(randi(64,64,1), 1:3)) * model';

end

%% do it again for the null

for draw = 1:5000

    for subject = 1:64
        combine_mat_perm(subject,randperm(3)) = combine_mat(subject, 1:3); 
    end

   distributionquad_perm(draw) = mean(combine_mat_perm(randi(64,64,1), 1:3)) * model';

end


 [BF] = bootstrap2BF_z(distributionquad,distributionquad_perm, 1);


%% compare the groups with three
% 1. Miso

for draw = 1:5000
   distributionquad_miso(draw) = mean(data_Miso_all_cond(randi(29,29,1), 1:3)) * model';
end


for draw = 1:5000
   distributionquad_controls(draw) = mean(data_Control_all_cond(randi(35,35,1), 1:3)) * model';
end

[BF] = bootstrap2BF_z(distributionquad_miso,distributionquad_controls, 1);

%% model with 4 conditions

% cuing
model = [1 -3 1 1].*-1; 

for draw = 1:5000
   distributionquad_miso4(draw) = mean(data_Miso_all_cond(randi(29,29,1), 1:4)) * model';
end


for draw = 1:5000
   distributionquad_controls4(draw) = mean(data_Control_all_cond(randi(35,35,1), 1:4)) * model';
end

[BF] = bootstrap2BF_z(distributionquad_controls4, distributionquad_miso4, 1);

%% compare the 4th condition
for draw = 1:5000
   distribution4_miso(draw) = mean(data_Miso_all_cond(randi(29,29,1), 4)); 
end


for draw = 1:5000
   distribution4_controls(draw) = mean(data_Control_all_cond(randi(29,29,1), 4)); 
end

[BF] = bootstrap2BF_z(distribution4_miso, distribution4_controls, 1);