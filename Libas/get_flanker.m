function [all] = get_flanker(filename)

fid = fopen(filename)

dumline = fgetl(fid);

line = 1
i = 1

while line > 0
		
		% read data
		
		line = fgets(fid);
		if length(line) <5, break, return, end
		
        tab_index = find(double(line)==9);
		underscore_index = find(double(line)==95);
        
        condition_SOA = line(1);
        condition_congruence = line(underscore_index(1)+1);
        RT = str2num(line(tab_index(2)+1:tab_index(3)));   
        hits = str2num(line(tab_index(4)+1:end));            
        
		if condition_SOA == '0', condition_vec_SOA(i) = 1;
		elseif condition_SOA == '1', condition_vec_SOA(i) = 2;
        else condition_vec_SOA(i) = 3;
		end
        
        if condition_congruence == 'k', condition_vec_congruence(i) = 1;
        else condition_vec_congruence(i) = 2;
		end
              
        
        RT_vec(i) = RT;
        hits_vec(i) = hits;
        RT_hits_vec = [RT_vec' hits_vec'];
        
 i = i + 1;       

end;

% Exlude misses and errors
a = find((RT_hits_vec(:,1) > 200)&(RT_hits_vec(:,2) == 1));
b = find((RT_hits_vec(:,1) < 200)|(RT_hits_vec(:,2) == 0));
RT_vec_hits = RT_vec(a);
condition_vec_SOA_hits = condition_vec_SOA(a);
condition_vec_congruence_hits = condition_vec_congruence(a);
RT_vec_misses_errors = RT_vec(b);
condition_vec_SOA_misses_errors = condition_vec_SOA(b);
condition_vec_congruence_misses_errors = condition_vec_congruence(b);
            
hits_mat = [condition_vec_SOA_hits' condition_vec_congruence_hits' RT_vec_hits'];
misses_errors_mat = [condition_vec_SOA_misses_errors' condition_vec_congruence_misses_errors' RT_vec_misses_errors'];

% 0 - kong

a = find((hits_mat(:,1)==1)&(hits_mat(:,2) == 1) & (hits_mat(:,3) < 2500));
kong_0 = hits_mat(a,3);
mean_kong_0 = mean(kong_0);

b = find((misses_errors_mat(:,1)==1)&(misses_errors_mat(:,2)==1));
misses_errors_kong_0 = length(b);

% 0 - inkong

a = find((hits_mat(:,1)==1)&(hits_mat(:,2) == 2) & (hits_mat(:,3) < 2500));
inkong_0 = hits_mat(a,3);
mean_inkong_0 = mean(inkong_0);

b = find((misses_errors_mat(:,1)==1)&(misses_errors_mat(:,2)==2));
misses_errors_inkong_0 = length(b);

% 100 - kong

a = find((hits_mat(:,1)==2)&(hits_mat(:,2) == 1) & (hits_mat(:,3) < 2500));
kong_100 = hits_mat(a,3);
mean_kong_100 = mean(kong_100);

b = find((misses_errors_mat(:,1)==2)&(misses_errors_mat(:,2)==1));
misses_errors_kong_100 = length(b);

% 100 - inkong

a = find((hits_mat(:,1)==2)&(hits_mat(:,2) == 2) & (hits_mat(:,3) < 2500));
inkong_100 = hits_mat(a,3);
mean_inkong_100 = mean(inkong_100);

b = find((misses_errors_mat(:,1)==2)&(misses_errors_mat(:,2)==2));
misses_errors_inkong_100 = length(b);


% 400 - kong

a = find((hits_mat(:,1)==3)&(hits_mat(:,2) == 1) & (hits_mat(:,3) < 2500));
kong_400 = hits_mat(a,3);
mean_kong_400 = mean(kong_400);

b = find((misses_errors_mat(:,1)==3)&(misses_errors_mat(:,2)==1));
misses_errors_kong_400 = length(b);

% 400 - inkong

a = find((hits_mat(:,1)==3)&(hits_mat(:,2) == 2) & (hits_mat(:,3) < 2500));
inkong_400 = hits_mat(a,3);
mean_inkong_400 = mean(inkong_400);

b = find((misses_errors_mat(:,1)==3)&(misses_errors_mat(:,2)==2));
misses_errors_inkong_400 = length(b);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

means_all = [mean_kong_0 mean_inkong_0 mean_kong_100 mean_inkong_100 mean_kong_400 mean_inkong_400]

misses_errors_all = [misses_errors_kong_0 misses_errors_inkong_0 misses_errors_kong_100 misses_errors_inkong_100 misses_errors_kong_400 misses_errors_inkong_400]

all = [means_all misses_errors_all]