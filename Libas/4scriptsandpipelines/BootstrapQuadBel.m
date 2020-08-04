% bootstrap quadratic regression
for iteration = 1:40000
    
    [upl_resamp,index] =  datasample(unpleasant, 41); 
    Pupl = polyfit(PCL(index),upl_resamp,2); 
    distribution_upl(iteration) = Pupl(1); 
    
end

[bin,quadcoef] = hist(distribution_upl,500);
critbin = sum(bin).*.95;
cumbins = cumsum(bin);
indices = find(cumbins > critbin);
index = min(indices);
quadcoef_975u = quadcoef(index)
    
[bin,quadcoef] = hist(distribution_upl,500);
critbin = sum(bin).*0.05;
cumbins = cumsum(bin);
indices = find(cumbins > critbin);
index = min(indices);
quadcoef_025u = quadcoef(index)


index = []; 

for iteration = 1:40000
    
    [ntr_resamp,index] =  datasample(neutral, 41); 
    Pntr = polyfit(PCL(index),ntr_resamp,2); 
    distribution_ntr(iteration) = Pntr(1); 
    
end

[bin,quadcoef] = hist(distribution_ntr,500);
critbin = sum(bin).*.95;
cumbins = cumsum(bin);
indices = find(cumbins > critbin);
index = min(indices);
quadcoef_975n = quadcoef(index)
    
[bin,quadcoef] = hist(distribution_ntr,500);
critbin = sum(bin).*0.05;
cumbins = cumsum(bin);
indices = find(cumbins > critbin);
index = min(indices);
quadcoef_025n = quadcoef(index)
% 
% % next try: based on ranks...
% PCLranks = ModifiedCompetitionRankings(PCL); 
% neutralRanks = ModifiedCompetitionRankings(neutral); 
% uplRanks = ModifiedCompetitionRankings(unpleasant); 
% 
% Pntrl = polyfit(PCLranks,neutralRanks,2)
% Pupl = polyfit(PCLranks,uplRanks,2)
% 
% Yupl = polyval(Pupl,PCLranks); SSRes = sum((Yupl-uplRanks).^2); SStotal = sum(uplRanks.^2); 
% 
% 
% 


