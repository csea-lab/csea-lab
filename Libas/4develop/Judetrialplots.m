% this is the single trial visualization script
cd '/Users/andreaskeil/Desktop/JudeGaborgen'

filemat = getfilesindir(pwd, '*win.mat');

sensor = 20;

startfileindex = 1:4:size(filemat,1);

for subject = 1:length(startfileindex)

    data4plot_temp = nan(4, 24);

    for condition = 1:4

        file2load = filemat(startfileindex(subject)+condition-1, :);

        load(file2load)

        tempdata  = outmat.fftamp;

        data4plot_temp(condition,1:size(tempdata,2)) = tempdata(sensor,:);

    end

    data4plot = [flipud(data4plot_temp(2:4,:)); data4plot_temp;];

    data4plot =  movmean(data4plot, 3,  2, 'omitnan');

    data4plot = z_norm(data4plot')';

    eval(['save ' file2load(1:4) 'trial4con_fft.mat data4plot -mat']);

    contourf(data4plot), title(file2load), colorbar, pause

end


% make a grand average
filemat4plots = getfilesindir(pwd, '*con_fft.mat');
avg4plotmat = avgmats_mat(filemat4plots);

contourf(avg4plotmat, 10), colorbar, title('grand mean')





