function [] = getresponse_wmgabor(filepath); 

a = load(filepath);

indices_1 = find(a(:,3)==1);
indices_2 = find(a(:,3)==2)
indices_3 = find(a(:,3)==3)
indices_4 = find(a(:,3)==4)
indices_5 = find(a(:,3)==5)

resp_nomatchtrials = a(indices_1,8) % in condition 1: NO match
falsealarm_vec = find(resp_nomatchtrials == 37); 
falsealarmrate = length(falsealarm_vec)./length(resp_nomatchtrials)


%next hitrate overall

 indices_matchall = find(a(:,3)>1)
 resp_match = a(indices_matchall,8); 
 hits_vec = find(resp_match == 37); 
hitrate = length(hits_vec)./length(resp_match)

%next hitrate BY CONDITION
% conditions 2 to 5

resp_match_2 = a(indices_2,8); 
 hits_vec_2 = find(resp_match_2 == 37); 
hitrate_2 = length(hits_vec_2)./length(resp_match_2)

resp_match_3 = a(indices_3,8); 
 hits_vec_3 = find(resp_match_3 == 37); 
hitrate_3 = length(hits_vec_3)./length(resp_match_3)

resp_match_4 = a(indices_4,8); 
 hits_vec_4 = find(resp_match_4 == 37); 
hitrate_4 = length(hits_vec_4)./length(resp_match_4)

resp_match_5 = a(indices_5,8); 
 hits_vec_5 = find(resp_match_5 == 37); 
hitrate_5 = length(hits_vec_5)./length(resp_match_5)