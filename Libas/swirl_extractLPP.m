% ------------------------------------------------------------------------------
%% Extract LPP for swirl studies 1 and 2
% ------------------------------------------------------------------------------
% srt: 400
% stp: 600
% cluster: [52 53 44 45 81 9 186 257 132 144 185 184]
function[picGO, picNOGO, swirlGO, swirlNOGO, info] = swirl_extractLPP(srt, stp, cluster)

    info            = [];
    info.srt        = srt;
    info.stp        = stp;  
    info.cluster    = cluster;
    % INPUT
        % srt = start of extracted time window (in ms) - must be divisible by 4
        % stp = end of extracted time window (in ms) - must be divisible by 4
%     srt = 400; % ms (must be a multiple of 4)
%     stp = 550; % 548; % ms
%     % LPP_cluster = [80 131 79 143 8 9 130 88 142 100 129]; %[89 130 100 129 101]; % ask AK if this is right... this is a circle around Cz
%     LPP_cluster = [89 130 90 80 81 131 132];

%     LPP_cluster = [52 53 44 45 81 9 186 257 132 144 185 184];
    %% study 1
    picGO = [];
    picNOGO = [];
    for p = [1, 3:10, 13:17, 19]
        clear LPP_go LPP_nogo
        [LPP_go, LPP_nogo] = swirl_getLPP(p, srt, stp, cluster);
        picGO(p,:) = LPP_go;
        picNOGO(p,:) = LPP_nogo;
    end

    %% study 2
    swirlGO = [];
    swirlNOGO = [];
    for p = [3, 5:7, 9:12, 14, 16:17];
        clear LPP_go LPP_nogo
        [LPP_go, LPP_nogo] = swirl2_getLPP(p, srt, stp, cluster);
        swirlGO(p,:) = LPP_go;
        swirlNOGO(p,:) = LPP_nogo;
    end
end
%%

function [outmat,outmat2] = swirl_getLPP(p, st, sp, LPP_cluster)
    % study 1 (only GO trials- pics)
    % call from swirl_getconALL.m

    blockpath(1) = {'/Users/andreaskeil/Desktop/EEG data (at files for 2 studies)/study 1 - GO pics/Block1'};
    blockpath(2) = {'/Users/andreaskeil/Desktop/EEG data (at files for 2 studies)/study 1 - GO pics/Block2'};
    blockpath(3) = {'/Users/andreaskeil/Desktop/EEG data (at files for 2 studies)/study 1 - GO pics/Block3'};

    trigger = 105;
    sample_rate = 4;
    LPP_window = [(trigger + st/sample_rate):(trigger + sp/sample_rate)];
    BL_window = (trigger-200/sample_rate):trigger;

    for block = 1:3
        cd(blockpath{block});
        name = strcat('*', int2str(p), '.fh*');
        filemat = getfilesindir(cd, name);

        for con = 1:6
            file = filemat(con,:);
            data_noBLcorr = ReadAvgFile(deblank(file));
                BL_start = trigger-200/sample_rate;
            data = bslcorr(data_noBLcorr, BL_window);
            LPP(con) = mean(mean(data(LPP_cluster, LPP_window)));
        end
        blockmat(block,:) = [LPP];
    end

    outmat = [blockmat(1,:), blockmat(2,:), blockmat(3,:)];

    %%
    blockpath(1) = {'/Users/andreaskeil/Desktop/EEG data (at files for 2 studies)/study 1 - NOGO swirls/block 1'};
    blockpath(2) = {'/Users/andreaskeil/Desktop/EEG data (at files for 2 studies)/study 1 - NOGO swirls/block 2'};
    blockpath(3) = {'/Users/andreaskeil/Desktop/EEG data (at files for 2 studies)/study 1 - NOGO swirls/block 3'};

    trigger = 105;
    sample_rate = 4;
    LPP_window = [(trigger + st/sample_rate):(trigger + sp/sample_rate)];
    BL_window = (trigger-200/sample_rate):trigger;

    for block = 1:3
        cd(blockpath{block});
        name = strcat('*', int2str(p), '.fh*');
        filemat = getfilesindir(cd, name);

        for con = 1:6
            file = filemat(con,:);
            data_noBLcorr = ReadAvgFile(deblank(file));
                BL_start = trigger-200/sample_rate;
            data = bslcorr(data_noBLcorr, BL_window);
            LPP(con) = mean(mean(data(LPP_cluster, LPP_window)));
        end
        blockmat(block,:) = [LPP];
    end

    outmat2 = [blockmat(1,:), blockmat(2,:), blockmat(3,:)];
end


function [LPP_go, LPP_nogo] = swirl2_getLPP(p, st, sp, LPP_cluster)
    % study 1 (only GO trials- swirls)
    % call from swirl_getconALL.m
    % jesus christ why do I give these folders such long names!
    path = '/Users/andreaskeil/Desktop/EEG data (at files for 2 studies)/study 2';
    cd(path);
    trigger = 105;
    sample_rate = 4;
    LPP_window = [(trigger + st/sample_rate):(trigger + sp/sample_rate)];
    BL_window = (trigger-200/sample_rate):trigger;

    name = strcat('swirls2_', int2str(p), '*at*');
    filemat = getfilesindir(cd, name);

    go = filemat([7:12,19:24,31:36],:); % for GO swirls
    nogo = filemat([1:6,13:18,25:30],:); % for NOGO pictures


    LPP = [];
    for con = 1:18
        file = go(con,:);
        data_noBLcorr = ReadAvgFile(deblank(file));
            BL_start = trigger-200/sample_rate;
        data = bslcorr(data_noBLcorr, BL_window);
        LPP(con) = mean(mean(data(LPP_cluster, LPP_window)));
    end

    LPP_go = LPP;

    LPP = [];
    for con = 1:18
        file = nogo(con,:);
        data_noBLcorr = ReadAvgFile(deblank(file));
            BL_start = trigger-200/sample_rate;
        data = bslcorr(data_noBLcorr, BL_window);
        LPP(con) = mean(mean(data(LPP_cluster, LPP_window)));
    end

    LPP_nogo = LPP;
end


