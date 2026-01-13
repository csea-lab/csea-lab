% script for reashaping and then FFTing and the P2Acoupling with OCA alpha
% data for DOM
% settings
function [] = CFC_Dom(filemat, plotflag)
SampRate = 500;
thresholdTrials = 1.25;
elecsmidline= [26 21 15 8 257 90 101 119 126 137 147]; elecslefthemi = [48 56 63 70 75 85 96 106 114 122]; elecsrighthemi = [222 212 203 193 180 171 170 169 168 167];
elecs_select = [elecslefthemi elecsmidline elecsrighthemi];

%% load data and reshape into 2-second segments
for fileindex = 1:size(filemat,1)
    temp = load(deblank(filemat(fileindex,:)));
    Mat3D = temp.Mat3D(elecs_select, :, :);
    size(Mat3D)
    data = reshape(Mat3D, [length(elecs_select), 1000, 62]);

    % throw out bad segments
    disp('artifact handling: epochs')
    [data, badindexvec, NGoodtrials ] = scadsAK_3dtrials(data, thresholdTrials);
    size(data)

    % FFT
    [specavg, freqs] = FFT_spectrum3D(data, 1:1000, 500);
    if plotflag
        figure, plot(freqs(3:60), specavg(:, 3:60)), pause(1)
    end

    % phase 2 amp coupling
    [CFCwithin, CFCacross, CFCwithin_norm, CFCacross_norm] = phaseampcouple_full(data, ...
        SampRate, 6, 39, 33, 2, 1, 1:1000, 0);
    
    %save the result
    save([deblank(filemat(fileindex,:)) 'CFC.mat'], 'CFCwithin', 'CFCacross', 'badindexvec')
end

