function [con] = dat2con_genface(datfilepath)

temp1 = dlmread(datfilepath); 

con = temp1(1:291,4)

con(1:70) = 0;
