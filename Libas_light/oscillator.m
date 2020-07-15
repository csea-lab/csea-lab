function wave = oscillator(varargin)
%OSCILLATOR generates a standard waveform, click train, or noise
% OSCILLATOR(wavetype,duration,frequency) 
%
% Input arguments:
%
%   wavetype (string):
%    'Sinusoid'
%    'Triangle'
%    'Square'
%    'Sawtooth'
%    'Reverse Sawtooth'
%    'Click Train'
%    'White Noise'
%    'Pink Noise'
%    'Speech Noise'
%
%   duration (in seconds)
%   frequency (in Hz)
%
% Optional input arguments:
%  OSCILLATOR(wavetype,duration,frequency,gate,phase,sample_freq) 
%   gate (in seconds): duration of a raised cosine on/off ramp
%   phase (in radians): starting phase of the waveform.
%   sample_freq (in samples): custom sample rates are possible
%
% Examples:
%
%   wave = OSCILLATOR('Sinusoid',1,1000); % simple pure tone at 1000 Hz.
%   wave = OSCILLATOR('Sawtooth',2,440); % 2 second sawtooth at 440 Hz.
%   wave = OSCILLATOR('Pink Noise',1); % 1 second of pink (1/F) noise
%   wave = OSCILLATOR('Sinusoid',1,220,0.01); %ramped on and off sinusoid
%   wave = OSCILLATOR('White Noise',1,[],0.1); %ramped on and off noise 
%   wave = OSCILLATOR('Sinusoid',1,220,0,pi/2,48000); %pure tone with a
%            starting phase of 90 degrees and sample rate set to 48000.
%
% Omitting 'wavetype' sets it to sinusoid, omitting 'duration' sets it to
% one second, and omitting 'frequency  sets it to 440 Hz. Gate is set to 0,
% phase to 0 and sample rate to 44100; All output waves are scaled from -1
% to 1. 

% (c) W. Owen Brimijoin - MRC Institute of Hearing Research
% Tested on Matlab R2011b and R14
% Version 1.0 18/05/12 - original
% Version 1.1 29/06/12 - added pink and speech-shaped noise options

%input handling:
switch nargin,
    case 0, wavetype='Sinusoid';duration=1;frequency=440;gate=0;phase=0;sample_rate=44100;
    case 1, wavetype=varargin{1};duration=1;frequency=440;gate=0;phase=0;sample_rate=44100;
    case 2, wavetype=varargin{1};duration=varargin{2};frequency=440;gate=0;phase=0;sample_rate=44100;
    case 3, wavetype=varargin{1};duration=varargin{2};frequency=varargin{3};gate=0;phase=0;
        sample_rate=44100;
    case 4, wavetype=varargin{1};duration=varargin{2};frequency=varargin{3};gate=varargin{4};
        phase=0;sample_rate = 44100;
    case 5, wavetype=varargin{1};duration=varargin{2};frequency=varargin{3};gate=varargin{4};
        phase=varargin{5};sample_rate = 44100;
    case 6, wavetype=varargin{1};duration=varargin{2};frequency=varargin{3};gate=varargin{4};
        phase=varargin{5};sample_rate = varargin{6};
    otherwise, error('incorrect number of input arguments');
end

%for noise, frequency is likely omitted, set to default to avoid error:
if isempty(frequency),frequency=440;end

%check the inputs:
if ~isstr(wavetype),
    error('1st argument ''wavetype'' must be a string.')
end
if ~isnumeric(duration) || numel(duration) ~= 1 || duration < 0 || ~isreal(duration),
    error('2nd argument ''duration'' must be a single positive number.')
end
if ~isnumeric(frequency) || numel(frequency) ~= 1 || frequency < 0 || ~isreal(frequency) || frequency>=sample_rate/2,
    error('3rd argument ''frequency'' must be a positive number less than or equal to the Nyquist (half the sample rate).')
end
if ~isnumeric(gate) || numel(gate) ~= 1 || gate < 0  || ~isreal(gate) || 2*gate>duration,
    error('optional 4th argument ''gate'' must be a positive number less than or equal to half the duration.')
end
if ~isnumeric(phase) || numel(phase) ~= 1 || ~isreal(phase),
    error('optional 5th argument ''phase'' should be a single number between -2pi and 2pi.')
end
if ~isnumeric(sample_rate) || numel(sample_rate) ~= 1 || sample_rate < 0 || ~isreal(sample_rate),
    error('optional 6th argument ''sample_rate'' must be a single positive number.')
end

num_samples = floor(sample_rate*duration);%duration in samples
phase = mod(phase,2*pi)/(2*pi); %phase rescaled from 2*pi to 1

switch lower(wavetype), %generate the chosen waveform:
    case 'sinusoid',
        % use in-built sine function, offset by the phase argument:
        wave = sin((2*pi*phase)+(2*pi*frequency*linspace(0,duration,num_samples)))';
    case 'triangle',
        % use modulo to fold a line from 0 to frequency, sign-reverse
        % positive values and rescale:
        wave =  2*mod(phase+.25+linspace(0,duration*frequency,num_samples)',1)-1;
        wave(wave>0) = -wave(wave>0);wave = 2*(wave+0.5);
    case 'square',
        % same as sinusoid...
        wave = sin((2*pi*phase)+(2*pi*frequency*linspace(0,duration,num_samples)))';
        % all positive values set to 1 and all negative values to -1:
        wave(wave>=0) = 1;wave(wave<0)=-1;
    case 'sawtooth',
        % simple modulo with phase added linearly:
        wave =  2*mod(phase+.25+linspace(0,duration*frequency,num_samples)',1)-1;
    case 'reverse sawtooth',
        % same as sawtooth...
        wave =  2*mod(phase+.25+linspace(0,duration*frequency,num_samples)',1)-1;
        % but sign-reversed:
        wave = -wave;
    case {'white noise','white','noise'},
        % use rand to create noise, wave is then normalized to a max of 1:
        wave = 2*(rand(num_samples,1)-0.5);wave = wave./max(abs(wave));    
    case {'click train','click'},
        % change phase argument to a fraction of the signal period:
        phase_offset = mod(round(-phase/frequency*sample_rate),round(1/frequency*sample_rate));
        % use the index 'phase offset' to specify location of 1 values:
        wave(phase_offset+round([1:1/frequency*sample_rate:num_samples])) = 1;
        % ensure that the signal is the correct duration:
        wave(1+num_samples)=0; wave = wave(1:num_samples)';
    case {'pink noise','pink'},
        % Julius O. Smith III's (Stanford) filter coefficients:
        B = [0.049922035 -0.095993537 0.050612699 -0.004408786];
        A = [1 -2.494956002 2.017265875 -0.522189400];
        % filter white noise and normalize:
        wave = filter(B,A,2*(rand(num_samples,1)-0.5));wave = wave./max(abs(wave));
    case {'speech noise','speech'},
        % Bernard Seeber's (MRC Institute of Hearing Research) filter
        % coefficients. Note that these coefficients were generated based
        % on the CCITT standard G.227 telephone signal. This is similar to
        % the long term spectrum of speech.
        B = [0.00396790391508 0.00032556793042 -0.00314367152058 -0.00104604251859 -0.0000887591994];
        A = [1 -3.39268359295324 4.31295903323020 -2.43473845585969 0.51493759484342];
        % filter white noise and normalize:
        wave = filter(B,A,2*(rand(num_samples,1)-0.5));wave = wave./max(abs(wave));
    otherwise,
       display('Unrecognized waveform type');wave = [];return
end

if gate>0,
    % create the raised cosine ramp:
    t = linspace(0,pi/2,floor(sample_rate*gate))'; gate = (cos(t)).^2;
    % ramp the beginning of the signal on:
    wave(1:length(gate)) = wave(1:length(gate)).*flipud(gate);
    % ramp the end of the signal off:
    wave(end-length(gate)+1:end) = wave(end-length(gate)+1:end).*gate;
end


    
    
    

