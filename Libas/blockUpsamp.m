tic
for sub = [10:14 17 20:23 28 31 33 34 37 39]
    load([num2str(sub) '_fullblocks.mat'],'fullBlock')
    for cond = 1:7
        eval(['dataBlock = fullBlock.at' num2str(cond) ';'])
        fprintf(['\n working on subj ' num2str(sub) ', cond ' num2str(cond)])
        xsp = 1;
        for samp = 1:100:size(dataBlock,2) % shifts every 200ms (100 SP)
            winSP = samp:samp+999; % gets a 2s window from sample point
            if winSP(end) > size(dataBlock,2)==1, samp = size(dataBlock,2);
            else
                for ss = [8.57 12]            
                    if ss == 8.57
                        magicNo = 3570; % # of SP to get around 6s with zero padding
                        Trgbin = 52; % fbin of 8.57
                        [~,winmat8(:,:,xsp), fftamp8(:,xsp), phasestabmat8(:,xsp), magmat8(:,:,xsp)] = ...
                            stead2singtrialsMatPAD(dataBlock(:,winSP), [], 1:150, 1:1000, ss, 600, 500,magicNo,Trgbin);  % bsl by first 300 ms, run window on full 2 s TR segemnts
                    elseif ss == 12
                        magicNo = 3600; % # of SP to get around 6s with zero padding
                        Trgbin = 73; % fbin of 12
                        [~,winmat12(:,:,xsp), fftamp12(:,xsp), phasestabmat12(:,xsp), magmat12(:,:,xsp)] = ... 
                            stead2singtrialsMatPAD(dataBlock(:,winSP), [], 1:150, 1:1000, ss, 600, 500,magicNo,Trgbin);
                    end % if freq loop
                end % freq
                xsp = xsp+1;
            end % if SP loop
        end % sample points
        
        eight.fftamp = fftamp8(:,1:2050); eight.phasestabmat = phasestabmat8(:,1:2050); eight.winmat = winmat8(:,:,1:2050);
%         eight.SNRadj = SNRadj8(:,1:2050); 
        eight.spec = magmat8(:,:,1:2050);
        
        twelve.fftamp = fftamp12(:,1:2050); twelve.phasestabmat = phasestabmat12(:,1:2050); twelve.winmat = winmat12(:,:,1:2050);
%         twelve.SNRadj = SNRadj12(:,1:2050); 
        twelve.spec = magmat12(:,:,1:2050);

        eightPAD = eight;
        twelvePAD = twelve;
        
    save(['/Volumes/Maeve7TB/Leipzig_Data/EEG/2sfft/0_fullblocks/' num2str(sub) '.at' num2str(cond) '_fftUPpad.mat'],'eightPAD','twelvePAD')
%     save(['/Volumes/Maeve7TB/Leipzig_Data/EEG/2sfft/0_fullblocks/' num2str(sub) '.at' num2str(cond) '_fftUPpad12.mat'],'twelvePAD')
%     save(['/Volumes/Maeve7TB/Leipzig_Data/EEG/2sfft/0_fullblocks/' num2str(sub) '.at' num2str(cond) '_fftUP.mat'],'eight', 'twelve')
    clearvars -except fullBlock cond sub
%     eval(['fft8.at' num2str(cond) ' = eight;'])
%     eval(['fft12.at' num2str(cond) ' = twelve;'])
    end % condition
%     save(['/Volumes/Maeve7TB/Leipzig_Data/EEG/2sfft/0_fullblocks/' num2str(sub) '_try2.mat'],'fullBlock', 'fft8','fft12')
    fprintf(['\n' num2str(toc/60) ' minutes so far \n'])
end % subjects
disp(['finished!!!! and it only took ' num2str(toc/60) ' minutes'])
%%
figure(9822)
subplot(2,1,1), bar([mean(eight.fftamp([9 10 20 31],:),2) mean(twelve.fftamp([9 10 20 31],:),2)]), box off, title('fft amp')
subplot(2,1,2), bar([mean(eight.SNRadj([9 10 20 31],:),2) mean(twelve.SNRadj([9 10 20 31],:),2)]), box off, title('snr')%%
%%
brik = BrikLoad('/Volumes/Maeve7TB/Leipzig_Data/r4_tlrc/r4s/r4.vp10.1.image.scale+tlrc.BRIK');
bold_max = squeeze(brik(36,69,33,:));
up_data = resample(bold_max,10,1);

lat_file = ['v10_1.txt'];
timevec = load(['/Volumes/Maeve7TB/Leipzig_Data/onsets/' lat_file]);
TRvec_all = round(timevec/2); % this gives TRs @ RDK onset
tr2050 = TRvec_all.*10;