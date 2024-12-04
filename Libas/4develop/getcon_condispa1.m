function [ conditionvector] = getcon_condispa1(datfilepath)

temp = load(datfilepath);

conditionvector = temp(:,6);
