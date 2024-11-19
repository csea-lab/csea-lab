% DirichletBootstest
load('/Users/andreaskeil/Downloads/keegan.mat')
b_mean = nan(1,5000);

% estimate mean std through essential bootstrap
for b_index = 1:5000
     b_data = keegan(randi(9, 9, 1), :);
     b_mean(b_index) = mean(mean(b_data'));
end

