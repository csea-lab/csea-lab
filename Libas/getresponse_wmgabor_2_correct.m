function [convecnew] = getresponse_wmgabor_2_correct(filepath); 

% last version mari and andreas april 28 2014
% get ready for correct (1) and incorrect (0) vector with 140 entries, to
% be used with eeg analysis

correctvec = zeros(140,1);

% start reading the data

a = load(filepath);

% find conditions

indices_1 = find(a(:,3)==1);
indices_2 = find(a(:,3)==2);
indices_3 = find(a(:,3)==3);
indices_4 = find(a(:,3)==4);
indices_5 = find(a(:,3)==5);
indices_6 = find(a(:,3)==6);
indices_7 = find(a(:,3)==7);

resp_nomatchtrials = a(indices_1,8); % in condition 1: NO match
falsealarm_vec = find(resp_nomatchtrials == 37);
falsealarmrate = length(falsealarm_vec)./length(resp_nomatchtrials)

% fill correctvec with correct rejections first - i.e. when they say NO in
% con 1
CorRejVec =  indices_1(find(resp_nomatchtrials == 39)); 
correctvec(CorRejVec) = 1; 

%next hitrate overall

 indices_matchall = find(a(:,3)>1);
 resp_match = a(indices_matchall,8); 
 hits_vec = find(resp_match == 37); 
hitrate = length(hits_vec)./length(resp_match);


% fill correctvec also with correct match responses (aka hits)
HitVec = indices_matchall(hits_vec);
correctvec(HitVec) = 1; 


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

resp_match_6 = a(indices_6,8); 
 hits_vec_6 = find(resp_match_6 == 37); 
hitrate_6 = length(hits_vec_6)./length(resp_match_6)

resp_match_7 = a(indices_7,8); 
 hits_vec_7 = find(resp_match_7 == 37); 
hitrate_7 = length(hits_vec_7)./length(resp_match_7)

% finally create condition file with correct vs incorrect
convecnew = a(:,3) .*10 + correctvec; 

