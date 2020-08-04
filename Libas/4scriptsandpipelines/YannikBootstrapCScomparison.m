
clear boot*

for x = 1:10000, subvec = ceil(rand(60,1).*67); boothabcsplus(x) = mean(habCSplus(subvec)); end

for x = 1:10000, subvec = ceil(rand(60,1).*67); boothabcsminus(x) = mean(habCSminus(subvec)); end

for x = 1:10000, subvec = ceil(rand(60,1).*67); bootacqcsminus(x) = mean(acqCSminus(subvec)); end

for x = 1:10000, subvec = ceil(rand(60,1).*67); bootacqcsplus(x) = mean(acqCSplus(subvec)); end

figure(1)
histogram(boothabcsminus, 'BinEdges', 2:0.1:5)
hold on 
histogram(boothabcsplus, 'BinEdges', 2:0.1:5)

hold off

figure(2)
histogram(bootacqcsminus, 'BinEdges', 2:0.1:5)
hold on 
histogram(bootacqcsplus, 'BinEdges', 2:0.1:5)

hold off

priohab = length(find(boothabcsminus < boothabcsplus))./length(boothabcsplus)
posterioracq = length(find(bootacqcsminus < bootacqcsplus))./length(bootacqcsplus)


priorOdds = priohab./(1-priohab) % converts likelihoods to odds   
posteriorOddsacq = posterioracq./(1-posterioracq) % converts likelihoods to odds   

BFacq = posteriorOddsacq./priorOdds

%%
% and for within effects (bootstrapping the mean of the within-participants CSplus-Csminus DIFFERENCE). Thus only the BFacq makes sense


for draw = 1:100
    
    for x = 1:100000, subvec = ceil(rand(67,1).*67); diffhab(x) = mean(habCSplus(subvec)-habCSminus(subvec)); end

    for x = 1:100000, subvec = ceil(rand(67,1).*67); diffacq(x) = mean(acqCSplus(subvec)-acqCSminus(subvec)); end

    figure(4)
    histogram(diffhab, 'BinEdges', -1:0.05:1)
    hold on 
    histogram(diffacq, 'BinEdges', -1:0.05:1)

    hold off

    priohab = length(find(diffhab > 0))./length(diffhab)
    posterioracq = length(find(diffacq > 0))./length(diffhab)

    priorOdds = priohab./(1-priohab) % converts likelihoods to odds   
    posteriorOddsacq = posterioracq./(1-posterioracq) % converts likelihoods to odds   

    BFacq(draw) = posteriorOddsacq./priorOdds;
    

end

SEM = std(BFacq)./sqrt(draw)
median(BFacq)

