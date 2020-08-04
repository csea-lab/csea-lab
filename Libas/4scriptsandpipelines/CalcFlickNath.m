% start with respective spectrum folder (For early and late, respectively)

% move dir to folder: 
filemat = getfilesindir(pwd)
%specs withous GMs:
filemat = filemat (1:48,:)

%%group1
filemat1 = filemat (1:20,:)
filemat2 = filemat (43:46,:)
group1= [filemat1; filemat2]

%%group2
filemat3 = filemat (21:42,:)
filemat4 = filemat (47:48,:)
group2= [filemat3; filemat4]

%% calculate spec bins
%for driving
get_tagbins(group1, 15, 'driv.face')
get_tagbins(group1, 22, 'driv.gabor')
get_tagbins(group2, 15, 'driv.gabor')
get_tagbins(group2, 22, 'driv.face')

%for harmonics
get_tagbins(group1, 29, 'harm.face')
get_tagbins(group1, 43, 'harm.gabor')
get_tagbins(group2, 43, 'harm.face')
get_tagbins(group2, 29, 'harm.gabor')


%% make new filemats

%driving spec bins 24 people
filemat = dir('*at1.ar.spec.driv.face*' )
drivface1SpecBin = char(filemat.name)

filemat = dir('*at1.ar.spec.driv.gabor*' )
drivgabor1SpecBin = char(filemat.name)

filemat = dir('*at2.ar.spec.driv.face*' )
drivface2SpecBin = char(filemat.name)

filemat = dir('*at2.ar.spec.driv.gabor*' )
drivgabor2SpecBin = char(filemat.name)

%harmonic spec bins 24 people
filemat = dir('*at1.ar.spec.harm.face*' )
harmface1SpecBin = char(filemat.name)

filemat = dir('*at1.ar.spec.harm.gabor*' )
harmgabor1SpecBin = char(filemat.name)

filemat = dir('*at2.ar.spec.harm.face*' )
harmface2SpecBin = char(filemat.name)

filemat = dir('*at2.ar.spec.harm.gabor*' )
harmgabor2SpecBin = char(filemat.name)


%% merge spec bins 
sub18vec = [1 3 4 6 7 8:16 19 22:24];

%Merge 24 People
MergeAvgFiles(drivface1SpecBin,'GM24.driv.Spec.at1.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(drivgabor1SpecBin,'GM24.driv.Spec.at2.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(drivface2SpecBin,'GM24.driv.Spec.at1.gabor' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(drivgabor2SpecBin,'GM24.driv.Spec.at2.gabor' ,1,1,[],0,[],[],0,0);

MergeAvgFiles(harmface1SpecBin,'GM24.harm.Spec.at1.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(harmgabor1SpecBin,'GM24.harm.Spec.at2.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(harmface2SpecBin,'GM24.harm.Spec.at1.gabor' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(harmgabor2SpecBin,'GM24.harm.Spec.at2.gabor' ,1,1,[],0,[],[],0,0);
fclose all
% Merge 18 People
MergeAvgFiles(drivface1SpecBin(sub18vec,:),'GM18.driv.Spec.at1.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(drivgabor1SpecBin(sub18vec,:),'GM18.driv.Spec.at2.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(drivface2SpecBin(sub18vec,:),'GM18.driv.Spec.at1.gabor' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(drivgabor2SpecBin(sub18vec,:),'GM18.driv.Spec.at2.gabor' ,1,1,[],0,[],[],0,0);

MergeAvgFiles(harmface1SpecBin(sub18vec,:),'GM18.harm.Spec.at1.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(harmgabor1SpecBin(sub18vec,:),'GM18.harm.Spec.at2.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(harmface2SpecBin(sub18vec,:),'GM18.harm.Spec.at1.gabor' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(harmgabor2SpecBin(sub18vec,:),'GM18.harm.Spec.at2.gabor' ,1,1,[],0,[],[],0,0);

fclose all
%% merge spec bins (driving+harmonic frequencies)
%merge harmonic and driving bins for each person
[drivface1SpecBin] = combineconditionsERP(drivface1SpecBin, harmface1SpecBin, 'freqmerge')
[drivface2SpecBin] = combineconditionsERP(drivface2SpecBin, harmface2SpecBin, 'freqmerge')
[drivgabor1SpecBin] = combineconditionsERP(drivgabor1SpecBin, harmgabor1SpecBin, 'freqmerge')
[drivgabor2SpecBin] = combineconditionsERP(drivgabor2SpecBin, harmgabor2SpecBin, 'freqmerge')

%make new filemats
specmerge = getfilesindir(pwd)
freqface1spec = specmerge (35:18:end,:)
freqface2spec = specmerge (44:18:end,:)
freqgabo1spec = specmerge (38:18:end,:)
freqgabor2spec = specmerge (47:18:end,:)

%%
%grand means: 24 people
MergeAvgFiles(freqface1spec,'GM24.freqmerge.Spec.at1.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(freqface2spec,'GM24.freqmerge.Spec.at2.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(freqgabo1spec,'GM24.freqmerge.Spec.at1.gabor' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(freqgabor2spec,'GM24.freqmerge.Spec.at2.gabor' ,1,1,[],0,[],[],0,0);
 
%grand means:  18 people
MergeAvgFiles(freqface1spec(sub18vec,:),'GM18.freqmerge.Spec.at1.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(freqface2spec(sub18vec,:),'GM18.freqmerge.Spec.at2.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(freqgabo1spec(sub18vec,:),'GM18.freqmerge.Spec.at1.gabor' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(freqgabor2spec(sub18vec,:),'GM18.fregmerge.Spec.at2.gabor' ,1,1,[],0,[],[],0,0);

fclose all
%% calculate SNR bins

%%for driving:
%gruppe1
[topo_SNR] = get_tagbinsSNR(group1, 22, [18:20 24:26], 'driv.gabor' )
[topo_SNR] = get_tagbinsSNR(group1, 15, [11:13 17:19], 'driv.face')
%gruppe2
[topo_SNR] = get_tagbinsSNR(group2, 15, [11:13 17:19], 'driv.gabor')
[topo_SNR] = get_tagbinsSNR(group2, 22, [18:20 24:26], 'driv.face' )

%%Harmonische
%gruppe1
[topo_SNR] = get_tagbinsSNR(group1, 43, [39:41 45:47], 'harm.gabor' )
[topo_SNR] = get_tagbinsSNR(group1, 29, [25:27 31:33], 'harm.face')
%gruppe2
[topo_SNR] = get_tagbinsSNR(group2, 29, [25:27 31:33],'harm.gabor')
[topo_SNR] = get_tagbinsSNR(group2, 43, [39:41 45:47], 'harm.face' )

%% make SNR filemats

%driving
filemat = dir('*at1.ar.spec.SNR.driv.face*' )
drivface1SNR = char(filemat.name)

filemat = dir('*at1.ar.spec.SNR.driv.gabor*' )
drivgabor1SNR = char(filemat.name)

filemat = dir('*at2.ar.spec.SNR.driv.face*' )
drivface2SNR = char(filemat.name)

filemat = dir('*at2.ar.spec.SNR.driv.gabor*' )
drivgabor2SNR = char(filemat.name)

%harmonics
filemat = dir('*at1.ar.spec.SNR.harm.face*' )
harmface1SNR = char(filemat.name)

filemat = dir('*at1.ar.spec.SNR.harm.gabor*' )
harmgabor1SNR = char(filemat.name)

filemat = dir('*at2.ar.spec.SNR.harm.gabor*' )
harmgabor2SNR = char(filemat.name)

filemat = dir('*at2.ar.spec.SNR.harm.face*' )
harmface2SNR = char(filemat.name)

%% merge 24 people
MergeAvgFiles(drivface1SNR,'GM24.driv.SNR.at1.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(drivgabor1SNR,'GM24.driv.SNR.at2.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(drivface2SNR,'GM24.driv.SNR.at1.gabor' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(drivgabor2SNR,'GM24.driv.SNR.at2.gabor' ,1,1,[],0,[],[],0,0);

MergeAvgFiles(harmface1SNR,'GM24.harm.SNR.at1.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(harmgabor1SNR,'GM24.harm.SNR.at2.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(harmface2SNR,'GM24.harm.SNR.at1.gabor' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(harmgabor2SNR,'GM24.harm.SNR.at2.gabor' ,1,1,[],0,[],[],0,0);

%%Merge 18 People
sub18vec2 = [1 3 4 6 7 8:16 19 22:24];

MergeAvgFiles(drivface1SNR(sub18vec2,:),'GM18.driv.SNR.at1.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(drivgabor1SNR(sub18vec2,:),'GM18.driv.SNR.at2.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(drivface2SNR(sub18vec2,:),'GM18.driv.SNR.at1.gabor' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(drivgabor2SNR(sub18vec2,:),'GM18.driv.SNR.at2.gabor' ,1,1,[],0,[],[],0,0);

MergeAvgFiles(harmface1SNR(sub18vec2,:),'GM18.harm.SNR.at1.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(harmgabor1SNR(sub18vec2,:),'GM18.harm.SNR.at2.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(harmface2SNR(sub18vec2,:),'GM18.harm.SNR.at1.gabor' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(harmgabor2SNR(sub18vec2,:),'GM18.harm.SNR.at2.gabor' ,1,1,[],0,[],[],0,0);

%% merge SNR bins (driving+harmonic frequencies)
%merge harmonic and driving bins for each person
[face1SNR] = combineconditionsERP(drivface1SNR, harmface1SNR, 'freqmerge')
[face2SNR] = combineconditionsERP(drivface2SNR, harmface2SNR, 'freqmerge')
[gabor1SNR] = combineconditionsERP(drivgabor1SNR, harmgabor1SNR, 'freqmerge')
[gabor2SNR] = combineconditionsERP(drivgabor2SNR, harmgabor2SNR, 'freqmerge')

%make new filemats
SNRmerge = getfilesindir(pwd)
freqface1SNR = SNRmerge (83:34:end,:)
freqface2SNR = SNRmerge (100:34:end,:)
freqgabo1SNR = SNRmerge (86:34:end,:)
freqgabo2SNR = SNRmerge (103:34:end,:)

%merge 24 people
MergeAvgFiles(freqface1SNR,'GM24.freqmerge.SNR.at1.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(freqface2SNR,'GM24.freqmerge.SNR.at2.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(freqgabo1SNR,'GM24.freqmerge.SNR.at1.gabor' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(freqgabo2SNR,'GM24.freqmerge.SNR.at2.gabor' ,1,1,[],0,[],[],0,0);

%merge 18 people
MergeAvgFiles(freqface1SNR(sub18vec,:),'GM18.freqmerge.SNR.at1.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(freqface2SNR(sub18vec,:),'GM18.freqmerge.SNR.at2.face' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(freqgabo1SNR(sub18vec,:),'GM18.freqmerge.SNR.at1.gabor' ,1,1,[],0,[],[],0,0);
MergeAvgFiles(freqgabo2SNR(sub18vec,:),'GM18.freqmerge.SNR.at2.gabor' ,1,1,[],0,[],[],0,0);

fclose all
%% End
