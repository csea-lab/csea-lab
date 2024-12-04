function [ conditionvector] = getcon_condispa(datfilepath)

temp = load(datfilepath);

%conditionvector = temp(:,6);
conditionvector = temp(:,7)+6;