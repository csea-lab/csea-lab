% this script requires the volplot and triplot functions, which both can
% be found in the private directory of fieldtrip. Futhermore, it requires
% the image processing toolbox for the segmentations, and the SPM2 toolbox
% for reading the example anatomical data.

% the prepare_bemmodel function is available upon request
% the dipoli stand-alone executable is available upon request

% read the anatomical MRI: this template MRI is available from 
% http://www.bic.mni.mcgill.ca/brainweb/selection_normal.html
% note that this MRI is aligned with MNI/SPM coordinates, if you have 
% a custom MRI you should ensure that it is aligned with the desired 
% coordinates using the homogenous transformation matrix
mri = read_mri('   ');
% downsample volume ? 

cfg.downsample = 2;
[mri] = downsampcarsonMR(cfg, '    ');

% % This did not work: segmenting routine in spm recognizes the dicom dimensions in the 
% mri.img file OK, but not the ones with the same transformation matrix that are changed by myself  
% if necessary, bring into spm cordinates
% mri2 = mri
% mri2.anatomy = permute(mri.anatomy, [3,1,2])
% mri2.dim = [160 256 256]
% %sourceplot(cfg,mri2)
% mri2.anatomy = flipdim(mri2.anatomy,2);
% 
% %save SPM coordinate file
% cfgexp.scaling = 'no';
% cfgexp.parameter = 'anatomy';
% cfgexp.filename = ['s210spm'];
% cfgexp.filetype = 'analyze';
% cfgexp.coordinates = 'spm';
% cfgexp.datatype = 'float';
% volumewrite(cfgexp, mri2)
% 
% mri = read_mri('s210spm.img')

% construct a segmentation of the brain, i.e. gray+white+csf
% these cannot be directly used for the BEM model, but serve as starting point
cfg = []; 
    cfg.segment = 'yes';
    cfg.smooth = 'no';
    cfg.template = '/Users/andreaskeil/matlab_as/spm5/templates/T1.nii';
    cfg.write = 'no';
    cfg.coordinates = 'spm';
    cfg.mriunits = 'mm';

    [seg] = volumesegment_as(cfg, mri, cfgas.path);

% due to a bug in volumesegment, the segmentations should be flipped
% in case of an CTF-oriented MRI, but not in case of an SPM-oriented one
% seg.gray  = flipdim(flipdim(flipdim(seg.gray , 3), 2) ,1);
% seg.white = flipdim(flipdim(flipdim(seg.white, 3), 2) ,1);
% seg.csf   = flipdim(flipdim(flipdim(seg.csf  , 3), 2) ,1);

% the construction of the segmentations uses the image processing toolbox
% basically this requires a lot of trial-and-error, with "volplots" in between

% construct a segmentation of the brain compartment
brain = (seg.csf>140);
s = strel_bol(10);
brain = imclose(brain, s);
% brain = imopen(brain, s);
brain = imdilate(brain, strel_bol(8));
brain = imfill(brain, 'holes');

% construct a segmentation of the skin compartment
skin = (mri.anatomy>60);
% remove the bar at top of head
%skin = bwlabeln(skin);

%skin = (skin~=0);
% close the ear holes using lower threshold
skin(125:195,90:160,4:70) = mri.anatomy(125:195,90:160,4:70)>2;
skin(125:195,90:160,110:155) = mri.anatomy(125:195,90:160,110:155)>2;
% get rid of junk at the edges
skin(:,:,1:5) = 0;
skin(:,:,155:160) = 0;
skin(250:256,:,:) = 0;
skin(:,1:45,:) = 0;
s = strel_bol(5);
skin = imclose(skin, s);
%skin(:,:,1) = 1;
skin = imfill(skin, 'holes');
skin = imdilate(skin, strel_bol(2));
skin = imclose(skin, s);
skin = imfill(skin, 'holes');


% construct a segmentation of the skull compartment
s = strel_bol(5);
skin_a  = imerode(skin, s);
brain_a = imdilate(brain, s);
skull = (brain_a & skin_a);

% make figures of the segmentations, click around in the figures
volplot(skin  .* mri.anatomy)
volplot(skull .* mri.anatomy)
volplot(brain .* mri.anatomy)
volplot(brain+skull+skin);

% add the BEM segmentation to the anatomical MRI for convenience
% skin = 1, skull = 2, brain = 3
mri.seg = skin+skull+brain;

% construct the triangulated surfaces and compute the BEM model
cfg                = [];
cfg.tissue         = [3 2 1]; % value of each tissue type in the segmentation
cfg.numvertices    = [3000 2000 1000];
cfg.conductivity   = [1 1/80 1];
cfg.isolatedsource = false;
cfg.method         = 'bemcp';

vol = prepare_bemmodel(cfg, mri);

% make figures of the surfaces, note that the brain and skull surface
% should be slightly smoother an additional convolution and threshold of
% their respective segmentations probably would achieve that
figure; triplot(vol.bnd(1).pnt, vol.bnd(1).tri, [], 'faces_skin'); rotate3d
figure; triplot(vol.bnd(2).pnt, vol.bnd(2).tri, [], 'faces_skin'); rotate3d
figure; triplot(vol.bnd(3).pnt, vol.bnd(3).tri, [], 'faces_skin'); rotate3d

% write the BEM model to a matlab file, it can be later specified in
% sourceanalysis or dipolefitting as cfg.hdmfile='vol.mat'
save vol.mat vol mri
