%%
clear
cd '/Users/andreaskeil/Desktop/MPP_atFiles/beta'

searchstring = '*long.at11.ar'

savestring = searchstring; 

savestring([1, strfind(searchstring, '.')]) = []; 

filemat = getfilesindir(pwd, searchstring)

taxis = -2600:2:2600; 

for sub = 1:29

    dataPP = ReadAvgFile(deblank(filemat(sub,:)));

    if size(dataPP,1) == 128;
        dataPP = [dataPP; dataPP(55,:)]; 
    end

        for sens = 1:129
            dataConv(sens,:) = conv(dataPP(sens,:), gausswin(300));        
        end

        SaveAvgFile(['Conv_' deblank(filemat(sub,:))], dataConv, [], [], 500);

       if sub ==1
        datasum = dataConv; 
       else
        datasum  = datasum + dataConv; 
       end

      %  plot(dataConv'), pause(1)

end

%datasum = [datasum; datasum(55,:)];

eval(['sum' savestring ' = datasum;'])

%SaveAvgFile(['sumgam' searchstring(2:end)], datasum, [], [], 500);

%%