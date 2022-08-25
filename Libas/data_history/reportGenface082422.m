%% %% [0.5 -1 -2 5 -2 -1 0.5]
for elec = 1:129 
  for time = 1:1501
      for subject = 1:61
            innerprodmat1(elec,time, subject) = squeeze(repmat(elec, time, subject, 1:7))' * [0.5 -1 -2 5 -2 -1 0.5]';
            innerprodmat2(elec,time, subject) = squeeze(repmat(elec, time, subject, 8:14))' * [0.5 -1 -2 5 -2 -1 0.5]';
      end
  end 
end

%% [0.5 -1 -2 5 -2 -1 0.5]
for elec = 1:129 
  for time = 1:1501
      temp1 = corrcoef(squeeze(innerprodmat1(elec, time, :)), lsas(:, 1)); 
      temp2 = corrcoef(squeeze(innerprodmat2(elec, time, :)), lsas(:, 1)); 
      
       corrmat_1(elec, time) = temp1(1,2); 
       corrmat_2(elec, time) = temp2(1,2); 
  end 
end

%% [-3 0.5 1.5 2 1.5 0.5 -3]
for elec = 1:129 
  for time = 1:1501
      for subject = 1:61
            innerprodmat1(elec,time, subject) = squeeze(repmat(elec, time, subject, 1:7))' * [-3 0.5 1.5 2 1.5 0.5 -3]';
            innerprodmat2(elec,time, subject) = squeeze(repmat(elec, time, subject, 8:14))' * [-3 0.5 1.5 2 1.5 0.5 -3]';
      end
  end 
end

%% [-3 0.5 1.5 2 1.5 0.5 -3]
for elec = 1:129 
  for time = 1:1501
      temp1 = corrcoef(squeeze(innerprodmat1(elec, time, :)), lsas(:, 1)); 
      temp2 = corrcoef(squeeze(innerprodmat2(elec, time, :)), lsas(:, 1)); 
      
       corrmat_1(elec, time) = temp1(1,2); 
       corrmat_2(elec, time) = temp2(1,2); 
  end 
end