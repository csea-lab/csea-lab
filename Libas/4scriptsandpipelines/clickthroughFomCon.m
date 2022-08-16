%clickthroughFOMcon

load('/Users/andreaskeil/Desktop/specmats4ak_fomcon.mat')
faxis = 0:1000/3500:500;

%% habituation
size(hab_spec_equi) 
% condition 1 and 2 
for subj = 1:28
    fh = figure(1);
    set(fh,'position',[1300 898 560 420])
    subplot(2,1,1), 
    plot(faxis(1:100), squeeze(hab_spec_equi(137, 1:100, 1:2, subj) )), xline(6), xline(3), xline(12)
    title(num2str(subj))
    subplot(2,1,2) 
    plot(squeeze(hab_spec_equi(:, 22, 1:2, subj))), xline(138)
    topomap(squeeze(hab_spec_equi(:, 22, 1:2, subj)))
    pause, close all
end
%%
%%%% habituation
size(hab_spec_equi) 
% condition 3 and 4 
for subj = 1:28
    fh = figure(1);
    set(fh,'position',[1300 898 560 420])
    subplot(2,1,1), 
    plot(faxis(1:100), squeeze(hab_spec_equi(137, 1:100, 3:4, subj) )), xline(6), xline(3), xline(12)
    title(num2str(subj))
    subplot(2,1,2) 
    plot(squeeze(hab_spec_equi(:, 22, 3:4, subj))), xline(138)
    topomap(squeeze(hab_spec_equi(:, 22, 3:4, subj)))
    pause, close all
end
%%
%%%% habituation
size(hab_spec_equi)  
% condition 5 and 6 
for subj = 1:28
    fh = figure(1);
    set(fh,'position',[1300 898 560 420])
    subplot(2,1,1), 
    plot(faxis(1:100), squeeze(hab_spec_equi(137, 1:100, 5:6, subj) )), xline(6), xline(3), xline(12)
    title(num2str(subj))
    subplot(2,1,2) 
    plot(squeeze(hab_spec_equi(:, 22, 5:6, subj))), xline(138)
    topomap(squeeze(hab_spec_equi(:, 22, 5:6, subj)))
    pause, close all
end

%

%% acquisition
size(acq_spec_equi) 
% condition 1 and 2 
for subj = 1:28 
    fh = figure(1);
    set(fh,'position',[1300 898 560 420])
    subplot(2,1,1), 
    plot(faxis(1:100), squeeze(acq_spec_equi(137, 1:100, 1:2, subj) )), xline(6), xline(3), xline(12)
    title(num2str(subj))
    subplot(2,1,2) 
    plot(squeeze(acq_spec_equi(:, 22, 1:2, subj))), xline(138)
    topomap(squeeze(acq_spec_equi(:, 22, 1:2, subj)))
    pause, close all
end
%%
%%%% habituation
size(acq_spec_equi) 
% condition 3 and 4 
for subj = 1:28
    fh = figure(1);
    set(fh,'position',[1300 898 560 420])
    subplot(2,1,1), 
    plot(faxis(1:100), squeeze(acq_spec_equi(137, 1:100, 3:4, subj) )), xline(6), xline(3), xline(12)
    title(num2str(subj))
    subplot(2,1,2) 
    plot(squeeze(acq_spec_equi(:, 22, 3:4, subj))), xline(138)
    topomap(squeeze(acq_spec_equi(:, 22, 3:4, subj)))
    pause, close all
end
%%
%%%% habituation
size(acq_spec_equi)  
% condition 5 and 6 
for subj = 1:28
    fh = figure(1);
    set(fh,'position',[1300 898 560 420])
    subplot(2,1,1), 
    plot(faxis(1:100), squeeze(acq_spec_equi(137, 1:100, 5:6, subj) )), xline(6), xline(3), xline(12)
    title(num2str(subj))
    subplot(2,1,2) 
    plot(squeeze(acq_spec_equi(:, 22, 5:6, subj))), xline(138)
    topomap(squeeze(acq_spec_equi(:, 22, 5:6, subj)))
    pause, close all
end
%%%
%% Difference
%% acquisition-habituation
diff = acq_spec_equi - hab_spec_equi; 
size(diff) 
% condition 1 and 2 
for subj = 1:28 
    fh = figure(1);
    set(fh,'position',[1300 898 560 420])
    subplot(2,1,1), 
    plot(faxis(1:100), squeeze(diff(137, 1:100, 1:2, subj) )), xline(6), xline(3), xline(12)
    title(num2str(subj))
    subplot(2,1,2) 
    plot(squeeze(diff(:, 22, 1:2, subj))), xline(138)
    topomap(squeeze(diff(:, 22, 1:2, subj)))
    pause, close all
end
%%
%%%% habituation
size(diff) 
% condition 3 and 4 
for subj = 1:28
    fh = figure(1);
    set(fh,'position',[1300 898 560 420])
    subplot(2,1,1), 
    plot(faxis(1:100), squeeze(diff(137, 1:100, 3:4, subj) )), xline(6), xline(3), xline(12)
    title(num2str(subj))
    subplot(2,1,2) 
    plot(squeeze(diff(:, 22, 3:4, subj))), xline(138)
    topomap(squeeze(diff(:, 22, 3:4, subj)))
    pause, close all
end
%%
%%%% habituation
size(diff)  
% condition 5 and 6 
for subj = 1:28
    fh = figure(1);
    set(fh,'position',[1300 898 560 420])
    subplot(2,1,1), 
    plot(faxis(1:100), squeeze(diff(137, 1:100, 5:6, subj) )), xline(6), xline(3), xline(12)
    title(num2str(subj))
    subplot(2,1,2) 
    plot(squeeze(diff(:, 22, 5:6, subj))), xline(138)
    topomap(squeeze(diff(:, 22, 5:6, subj)))
    pause, close all
end
%%%


%% Difference of diff
%% acquisition-habituation
% change indices below
diffdiff = diff(:, :, 6, :) - diff(:, :, 5, :); 
size(diffdiff) 
% condition 1 and 2            
for subj = 1:28 
    fh = figure(1);
    set(fh,'position',[1300 898 560 420])
    subplot(2,1,1), 
    plot(faxis(1:100), squeeze(diff(137, 1:100, subj) )), xline(6), xline(3), xline(12)
    title(num2str(subj))
    subplot(2,1,2) 
    plot(squeeze(diff(:, 22,  subj))), xline(138)
    topomap(squeeze(diff(:, 22, subj)))
    pause, close all
end

%% 
diffdiff_face = squeeze(diff(:, :, 2, :) - diff(:, :, 1, :)); 
diffdiff_gabor = squeeze(diff(:, :, 4, :) - diff(:, :, 3, :)); 
diffdiff_dots = squeeze(diff(:, :, 6, :) - diff(:, :, 5, :)); 

