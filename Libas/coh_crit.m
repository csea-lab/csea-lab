% This is one of a range of functions that can help the user to select a
% statistical threshold for evaluating a connectivity matrix. This one was
% written to evaluate a threshold for magnitude squared coherence values in
% user-defined frequecny bands.
% It works by generating 2 independent white noise signals with durations equal to the EEG recording, computing
% coherence between them and repeating this for a random 200 shuffles. All
% of the coherence values are then collated and the threshold is determined depending on
% the percentile rank chosen by the user (e.g., 95%, 99%th percentile).
% Note that the critical R values will obviously differ from run to run.
% inputs: sig_dur : signal duration in sample points
%         fs: sampling rate
%         minf: lower boundary of the desired frequency range
%         maxf: upper boundary of the desired frequency range
% For further reading see Lachaux et al.,(2000) Int J Bifurcation and Chaos

function[critR] = coh_crit(sig_dur,fs,minf,maxf);

% First, query the user to select the desired percentile level at which to
% apply the cut-off
[percent] = input('Enter desired cut-off in percentile (%) points:');

% Now determine frequency range within which to measure the surrogate
% coherence values
faxis = 0:1000/((1000/fs)*sig_dur):fs/2;
%first figure out which frequency bins are needing to be averaged
%calculate lower frequency boundary
min_diff_vec = faxis-minf;
min_diff_vec = abs(min_diff_vec);
act_minf=find(min_diff_vec==min(min_diff_vec)); %the actual bin in the faxis corresponding to the desired lower bound

%calculate higher frequency boundary
max_diff_vec = faxis-maxf;
max_diff_vec = abs(max_diff_vec);
act_maxf=find(max_diff_vec==min(max_diff_vec)); %the actual bin in the faxis corresponding to the desired lower bound

% Generate white noise signals, estimate magnitude squared coherence and
% repeat 200x; take the desired percentile-value
coh_vec=[];
for draws = 1:200;
    x1=randn((sig_dur),1);
    y1=randn((sig_dur),1);
    [Cxy,f] = mscohere(x1,y1,[],[],(sig_dur),(fs));
    coh_vec=[coh_vec Cxy];   
end
freq_range=coh_vec([act_minf:act_maxf],:);
allval = sort(nonzeros(freq_range),'descend');
critR = prctile(allval,percent);
disp('The critical R is:')
    disp(critR)