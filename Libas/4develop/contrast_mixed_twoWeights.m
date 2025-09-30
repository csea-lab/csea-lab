function [F_w, r_w, F_b, r_b, F_int, r_int] = ...
         contrast_mixed_twoWeights(repeatmat,groupvec,w1,w2)
% -------------------------------------------------------------------------
% Mixed‑factor contrast with group‑specific within‑subject weights.
% -------------------------------------------------------------------------

% ---------- 0.  Basic checks ----------
% repeatmat = sort4trend(repeatmat);               % keep your helper
[chan, nSubj, nCond] = size(repeatmat);

if length(w1) ~= nCond || length(w2) ~= nCond
    error('Length of each weight vector must equal the number of conditions.');
end
if abs(sum(w1)) > 1e-10 || abs(sum(w2)) > 1e-10
    error('Both weight vectors must sum to zero.');
end

% Groups must be exactly two distinct values
uniqG = unique(groupvec);
if numel(uniqG) ~= 2
    error('groupvec must contain exactly two groups.');
end
% Convert to binary 0/1 coding (group‑A = 0, group‑B = 1)
gBin = double(groupvec == uniqG(2));   % column vector nSubj×1

% Pre‑compute the two weight matrices (subject × condition)
W1mat = repmat(w1, nSubj, 1);         % [nSubj × nCond] for group A
W2mat = repmat(w2, nSubj, 1);         % [nSubj × nCond] for group B

% Group indicator matrix (repeated across conditions)
Gmat  = repmat(gBin, 1, nCond);       % [nSubj × nCond]

% -----------------------------------------------------------------
%  Pre‑allocate output vectors
% -----------------------------------------------------------------
F_w    = zeros(chan,1);
r_w    = zeros(chan,1);
F_b    = zeros(chan,1);
r_b    = zeros(chan,1);
F_int  = zeros(chan,1);
r_int  = zeros(chan,1);

% -----------------------------------------------------------------
%  Loop over channels (or time points)
% -----------------------------------------------------------------
for c = 1:chan
    % ---- raw data for this channel ----
    Y = squeeze(repeatmat(c,:,:));           % [nSubj × nCond]

    % ---- Grand‑mean corrected matrix (same as contrast_rep) ----
    GM  = mean(Y(:));                        % overall mean
    Yc  = Y - GM;                            % centre everything

    % ---- Build the four predictor columns (flattened) ----
    % 1) within‑subject weight for group A (zero for B)
    wA = W1mat .* (1-Gmat);                  % element‑wise
    % 2) within‑subject weight for group B (zero for A)
    wB = W2mat .* Gmat;
    % 3) simple group indicator (0/1)
    g  = Gmat(:);
    % Flatten the response vector
    y  = Yc(:);
    % Flatten the two weight columns
    wA = wA(:);
    wB = wB(:);
    
    % -----------------------------------------------------------------
    % 4.  Pooled error term (same residual matrix you used before)
    % -----------------------------------------------------------------
    % Remove subject means
    subjMean = mean(Yc,2);                % [nSubj×1]
    Yc_sub  = Yc - subjMean;              % broadcast subtraction
    % Remove condition means
    condMean = mean(Yc_sub,1);            % [1×nCond]
    R = Yc_sub - condMean;                % residual matrix
    SS_err = sum(R(:).^2);
    df_err = nSubj * (nCond-1);           % same as in contrast_rep
    MS_err = SS_err / df_err;

    % -----------------------------------------------------------------
    % 5.  Within‑subject contrast (averaged across groups)
    % -----------------------------------------------------------------
    % Average weight vector = (w1 + w2)/2, applied to *all* rows
    w_avg = (w1 + w2)/2;                           % row vector
    wavgMat = repmat(w_avg, nSubj, 1);
    Lw = sum(y .* wavgMat(:));
    SS_w = (Lw.^2) / (nSubj * sum(w_avg.^2));
    Fw = SS_w / MS_err;
    rw = sqrt(Fw/(Fw + df_err/(nCond-1)));

    % -----------------------------------------------------------------
    % 6.  Between‑group contrast (ignoring within pattern)
    % -----------------------------------------------------------------
    % Harmonic mean of the two group sizes (as in contrast_between)
    nA = sum(gBin==0);
    nB = sum(gBin==1);
    nh = 2 / (1/nA + 1/nB);                % harmonic mean

    % Group means on the *original* (grand‑mean‑removed) data
    meanA = mean(y(g==0));
    meanB = mean(y(g==1));
    % Build T‑vector (weighted means)
    T = nh * [meanA , meanB];
    % Use simple contrast [-1 1] (any zero‑sum vector works)
    SS_g = (sum(T .* [-1 1]).^2) / (nh * sum([-1 1].^2));
    Fb = SS_g / MS_err;
    rb = sqrt(Fb/(Fb + df_err/(nCond-1)));

    % -----------------------------------------------------------------
    % 7.  Interaction contrast (different weights per group)
    % -----------------------------------------------------------------
    % The interaction column is simply the *difference* of the two
    % group‑specific weight columns:
    %   w_int = wA - wB   (because wA is zero for group B and vice‑versa)
    %   which is equivalent to (w1 - w2) applied with the appropriate group mask
    w_int = wA - wB;                     % vector length nSubj*nCond
    Lint = sum(y .* w_int);
    % Note: sum( (w1 - w2).^2 ) is the denominator for the contrast
    denom_int = nSubj * sum( (w1 - w2).^2 );
    SS_int = (Lint.^2) / denom_int;
    Fi = SS_int / MS_err;
    ri = sqrt(Fi/(Fi + df_err/(nCond-1)));

    % -----------------------------------------------------------------
    % 8.  Store results
    % -----------------------------------------------------------------
    F_w(c)   = Fw;
    r_w(c)   = rw;
    F_b(c)   = Fb;
    r_b(c)   = rb;
    F_int(c) = Fi;
    r_int(c) = ri;
end
end