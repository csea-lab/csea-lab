function [ conditionvector] = getcon_condispa2(datfilepath)

temp = load(datfilepath);

%conditionvector = temp(:,6);
conditionvector = temp(:,7)+6;