function [ conditionvector] = getcon_COARD_comp(datfilepath)

temp = load(datfilepath);

conditionvector = temp(:,3);