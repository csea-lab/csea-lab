model = svmtrain([], heart_scale_label, heart_scale_inst);
[predict_label, accuracy, prob_estimates] = svmpredict(heart_scale_label, heart_scale_inst, model);
w = (model.sv_coef' * full(model.SVs));