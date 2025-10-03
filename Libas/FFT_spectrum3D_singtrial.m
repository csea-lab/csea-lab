function [ampout3d, phaseout3d, freqs] = FFT_spectrum3D_singtrial(Data3d, timewinSP, SampRate, baselineSP)
% Applies baseline correction and single-trial FFT to 3D EEG data.
%
% Inputs:
% - Data3d: 3D matrix [channels x timepoints x trials]
% - timewinSP: indices of timepoints to use for FFT (e.g., 961:1861 for 0–1500 ms)
% - SampRate: sampling rate in Hz (e.g., 600)
% - baselineSP: indices of timepoints to use for baseline correction (e.g., 601:960 for -600 to 0 ms)
%
% Outputs:
% - ampout3d: amplitude spectrum [channels x frequencies x trials]
% - phaseout3d: phase spectrum [channels x frequencies x trials]
% - freqs: frequency vector in Hz

% Compute frequency resolution and frequency vector
fRes = 1000 / (length(timewinSP) * (1000 / SampRate));
freqs = 0:fRes:SampRate / 2;

[num_chans, ~, num_trials] = size(Data3d);

for trial = 1:num_trials
    % === Extract trial data ===
    trial_data = squeeze(Data3d(:, :, trial));  % size: [channels x timepoints]
    
    % === Baseline correction ===
    baseline = mean(trial_data(:, baselineSP), 2);   % average across selected baseline timepoints
    trial_data = trial_data - baseline;              % subtract baseline from all timepoints
    
    % === Select time window for FFT ===
    Data = trial_data(:, timewinSP);  % subset for FFT
    
    % === Apply Hanning window ===
    Data = Data .* cosinwin(20, size(Data,2), size(Data,1));  % apply cosine window
    
    % === Perform FFT ===
    NFFT = size(Data, 2);
    fftMat = fft(Data', NFFT);         % FFT expects timepoints x channels (transpose)
    Mag = abs(fftMat);                 % amplitude
    phase = angle(fftMat);             % phase
    
    % === Correct DC and Nyquist components ===
    Mag = Mag * 2;
    Mag(1,:) = Mag(1,:) / 2;
    if ~rem(NFFT, 2)  % if NFFT is even
        Mag(end,:) = Mag(end,:) / 2;
    end
    
    % === Normalize and reshape ===
    Mag = Mag' / NFFT;                % back to [channels x frequencies]
    phase = phase';                   % [channels x frequencies]

    % === Store results ===
    ampout3d(:, :, trial) = Mag(:, 1:round(NFFT/2));
    phaseout3d(:, :, trial) = phase(:, 1:round(NFFT/2));
end

end
