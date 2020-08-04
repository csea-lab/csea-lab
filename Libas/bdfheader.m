function [HDR] = bdfheader(inheader, data)

HDR = inheader;
x = data; 

VER   = version;
cname = computer;

% select file format 
%HDR.TYPE='GDF';
HDR.TYPE='EDF';
%HDR.TYPE='BDF'; 
%HDR.TYPE='CFWB';
%HDR.TYPE='CNT';

% set Filename
HDR.FileName = ['TEST.',HDR.TYPE];

% person identification, max 80 char
HDR.Patient.ID = 'P0000';	
HDR.Patient.Sex = 'F';
%HDR.Patient.Birthday = [1951 05 13 0 0 0];
%HDR.Patient.Name = 'X';		% for privacy protection  
HDR.Patient.Handedness = 0; 	% unknown, 1:left, 2:right, 3: equal


% recording identification, max 80 char.
HDR.RID = 'recording identification';

% recording time [YYYY MM DD hh mm ss.ccc]
HDR.T0 = clock	

% number of channels
HDR.NS = HDR.NS;

% Duration of one block in seconds
HDR.Dur = HDR.Dur;

% Samples within 1 block
%HDR.AS.SPR = [20;20;20;20;];	% samples per block;
%HDR.AS.SampleRate = [1000;100;200;100;20;0];	% samplerate of each channel
HDR.SampleRate = HDR.SampleRate;   

% channel identification, max 80 char. per channel
HDR.Label=HDR.Label; 

% Transducer, mx 80 char per channel
%HDR.Transducer = ['Ag-AgCl ';'Airflow ';'xyz     ';'        ';'        ';'Thermome'];

HDR.FLAG.UCAL = 0
HDR.TRIGGERED = 1

HDR.HeadLen = (900+75*HDR.NS),
% define datatypes (GDF only, see GDFDATATYPE.M for more details)
%HDR.GDFTYP = 3*ones(1,HDR.NS);

% define scaling factors 
HDR.PhysMax = HDR.PhysMax;
HDR.PhysMin = HDR.PhysMin;
HDR.DigMax  = ones(HDR.NS,1).* 28000;
HDR.DigMin  = ones(HDR.NS,1).* -28000;
HDR.Filter.Lowpass = [NaN];
HDR.Filter.Highpass = [NaN];
HDR.Filter.Notch = [NaN];

% define physical dimension
HDR.PhysDim = HDR.PhysDim;
%HDR.PhysDimCode = ones(1,HDR.NS);

t = [100:100:size(x,1)]';
%HDR.NRec = 100;
%HDR.VERSION = 1.0; 

%HDR = sopen(HDR,'w');
%%HDR.SIE.RAW = 0; % [default] channel data mode, one column is one channel 
%%HDR.SIE.RAW = 1; % switch to raw data mode, i.e. one column for one EDF-record

% HDR = swrite(HDR,x);
% 
% HDR.EVENT.POS = t;
% HDR.EVENT.TYP = t/100;
% if 1, 
% HDR.EVENT.CHN = repmat(0,size(t));
% HDR.EVENT.DUR = repmat(1,size(t));
% HDR.EVENT.VAL = repmat(NaN,size(t));
% ix = 6; 
% HDR.EVENT.CHN(ix) = 6; 
% HDR.EVENT.VAL(ix) = 373; % HDR.EVENT.TYP(ix) becomes 0x7fff
% ix = 8; 
% HDR.EVENT.CHN(ix) = 5; % not valid because #5 is not sparse sampleing
% HDR.EVENT.VAL(ix) = 374; 
% end; 
% 
% HDR = sclose(HDR);


%
%[s0,HDR0] = sload(HDR.FileName);	% test file 

%HDR0=sopen(HDR0.FileName,'r');
%[s0,HDR0]=sread(HDR0);
%HDR0=sclose(HDR0); 

%plot(s0-x)