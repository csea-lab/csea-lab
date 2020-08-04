% getcon_AB
% searches logfile and pulls out % correct values 

function [hitsbyblock, falsealbyblock] = getcon_mia(filepath)

percCorr = []; 

a = load(filepath); 

blockvec = a(:, 2); 
cycleofcoherent = a(:, 5); 
responsevec = a(:, 6); 
rtvec = a(:,7); 
conditionvec = a(:,8); 

condbyblockvec = blockvec *10 + conditionvec; 

% Block1 
indices12 = find(condbyblockvec == 12)
indices13 = find(condbyblockvec == 13)
indices11 = find(condbyblockvec == 11)

length(indices12)
length(indices13)

indiceshitsB1_12 = find(responsevec(indices12) == 1); 
indiceshitsB1_13 = find(responsevec(indices13) == 1); 
indicesfalsealB1 = find(responsevec(indices11) == 1); 

hitsB1_12 = length(indiceshitsB1_12)/length(indices12)
hitsB1_13 = length(indiceshitsB1_13)/length(indices13)
FalseAlarmsB1 = length(indicesfalsealB1)/length(indices11)


% Block2 
indices22 = find(condbyblockvec == 22)
indices23 = find(condbyblockvec == 23)
indices21 = find(condbyblockvec == 21);

length(indices22)
length(indices23)

indiceshitsB2_22 = find(responsevec(indices22) == 1); 
indiceshitsB2_23 = find(responsevec(indices23) == 1); 
indicesfalsealB2 = find(responsevec(indices21) == 1); 

hitsB2_22 = length(indiceshitsB2_22)/length(indices22)
hitsB2_23 = length(indiceshitsB2_23)/length(indices23)
FalseAlarmsB2 = length(indicesfalsealB2)/length(indices21)

% Block2 
indices32 = find(condbyblockvec == 32)
indices33 = find(condbyblockvec == 33)
indices31 = find(condbyblockvec == 31);

length(indices32)
length(indices33)

indiceshitsB3_32 = find(responsevec(indices32) == 1); 
indiceshitsB3_33 = find(responsevec(indices33) == 1); 
indicesfalsealB3 = find(responsevec(indices31) == 1); 

hitsB3_32 = length(indiceshitsB3_32)/length(indices32)
hitsB3_33 = length(indiceshitsB3_33)/length(indices33)
FalseAlarmsB3 = length(indicesfalsealB3)/length(indices31)

hitsbyblock = [hitsB1_12 hitsB1_13 hitsB2_22 hitsB2_23 hitsB3_32 hitsB3_33]

falsealbyblock = [ FalseAlarmsB1 FalseAlarmsB2 FalseAlarmsB3]



