filemat = getfilesindir(pwd, '*task*12.mat')

for x = 1:29

    a = load(filemat(x,:)); 
    
    temp = a.outmat; 

    data = squeeze(temp(75,:,:))'; 

    figure(99), plot(data(1,:)), hold on

    [D, MPP, th_opt] = PhEv_Learn_fast_2(data, 200, 4);

    eval(['save ' filemat(x,:) 'MPP.mat MPP -mat'])

    fprintf('.'), pause

end



%%
filemat = getfilesindir(pwd, '*matMPP.mat')

outvecall = []; 

for x = 1:29
a = load(filemat(x,:)); 

MPP = a.MPP; 

outvec = []; 

for index2 = 1: size(MPP, 2)
    temp  = MPP(index2).Trials; 
    outvec = [outvec temp.tau]
end

figure, hist(outvec), 
outvecall = [outvecall, outvec]; 
 
pause
end

