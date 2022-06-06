

job_counter = 1;    % counts "Jobs" 
n = 1;              % number of images
row = 1;            % count rows of multiple scans

%starting parameters to be adjusted
starting_image = 9;
final_image = 1030; %1030
projekt = 'Psychologie_020_';
fordner = '_fmri_pain_';
%ANPASSEN 1/2 Ende

%start_participant = input(['Wo geht' char(39) 's los? >> ']); ...
    % char(39) = Apostroph wird als String herausgegeben
%final_participant = input(['Wo h?rt' char(39) 's auf? >> ']);

vp = input ('Welche VPn sollen rein?');

n_vp = size(vp,2);

z = 1; 

for z = 1:n_vp
       
    i = vp(z);
        % i ist die Variable f?r die Versuchspersonen

    if i < 10
        k = '0';
    %elseif i < 100
    %    k = '0';
    else
        k = '';
    end

    
    
%% ---------------- STEP 1: CHANGE DIRECTORY -------------------- %%
    matlabbatch{job_counter}.cfg_basicio.cfg_cd.dir = {[pwd '\' projekt k num2str(i)]}; %#ok<*SAGROW>
 
    new_directory = [pwd '\' projekt k num2str(i) '\'];
    
    job_counter = job_counter + 1;
    
    cd (new_directory);

%ANPASSEN 2/2 Anfang ( wenn die EPI > 9 ist, z.b. ein sack voll Localizer,
%dann baut er "date" aus einer stelle weiter rechts bis ende)
    EPI = dir('*fmri_pain*'); 
    if EPI(1).name(3) == '1' 
        date = EPI(1).name(16:end);
    else 
        date = EPI(1).name(15:end);
    end;
%ANPASSEN 2/2 Ende
    
    version = EPI(1).name(1);
    
    if EPI(1).name(3) == '1' 
        EPI_number = EPI(1).name(3:4);
    else 
        EPI_number = EPI(1).name(3);
    end;
    
    T1 = dir ('*MPRAGE*');
    
    if T1(1).name(3) == '1' 
        T1_number = T1(1).name(3:4);
    else 
        T1_number = T1(1).name(3);
    end;
    
   % 
   %field = dir('*gre_field_mapping*');
   % if field(1).name(3) == '1'
   %     field_1_number = field(1).name(3:4);
   % else
   %     field_1_number = field(1).name(3);
   % end;
   % 
   % if field(2).name(3) == '1'
   %     field_2_number = field(2).name(3:4);
   % else
   %     field_2_number = field(2).name(3);
   % end;
    
    

%% ---------------- STEP 2: SLICE TIMING ------------------------ %%
    row = 1;
    
    for n = starting_image:final_image  % n gibt die Durchlaufanzahl an

        if n < 10             % if-Schleife, die f?r die richtige
            l = '000';         % Benennung des Scans sorgt
        elseif n < 100
            l = '00';
       elseif n < 1000
            l = '0';
        else 
            l = '';
        end
       
        matlabbatch{job_counter}.spm.temporal.st.scans{1,1}{row,1}...
            = [pwd '\' version '_' EPI_number fordner date ...
            '\' projekt k num2str(i) '_' version '_' EPI_number ...
            fordner date '_' l num2str(n) '_15.img,1'];

        row = row + 1;

    end;
    
    matlabbatch{job_counter}.spm.temporal.st.nslices = 25;
    matlabbatch{job_counter}.spm.temporal.st.tr = 2.5;
    matlabbatch{job_counter}.spm.temporal.st.ta = 2.4;
    matlabbatch{job_counter}.spm.temporal.st.so = ...
        [1 3 5 7 9 11 13 15 17 19 21 23 25 2 4 6 8 ...
        10 12 14 16 18 20 22 24];
    matlabbatch{job_counter}.spm.temporal.st.refslice = 13;
    matlabbatch{job_counter}.spm.temporal.st.prefix = 'a';

    job_counter = job_counter + 1;

    
%% ---------------- STEP 3: REALIGN AND UNWARP ------------------ %%
    
    row = 1;
    
    for n = starting_image:final_image  % n gibt die Durchlaufanzahl an

        if n < 10             % if-Schleife, die f?r die richtige
            l = '000';         % Benennung des Scans sorgt
        elseif n < 100
            l = '00';
       elseif n < 1000
            l = '0';
        else 
            l = '';
        end
        
        matlabbatch{job_counter}.spm.spatial.realignunwarp.data.scans {row,1}...
            = [pwd '\' version '_' EPI_number fordner date ...
            '\a' projekt k num2str(i) '_' version '_' EPI_number ...
            fordner date '_' l num2str(n) '_15.img,1'];        
    
        row = row + 1;

    end;
    
% da kommt das field mapping
                                                                            % Anpassen Namen dir
%
%matlabbatch{job_counter}.spm.spatial.realignunwarp.data.pmscan = ...
%        {[pwd '\' version '_' field_2_number '_gre_field_mapping' ...
%        date '\vdm5_scPsychologie_017_' k num2str(i) '_' version '_' field_2_number '_gre_field_mapping' date '_15.img,1']};
    
    
    
%    matlabbatch{job_counter}.spm.spatial.realignunwarp.data.pmscan = {'C:\FMRT\Psychologie015\Psychologie_015_001\1_3_gre_field_mapping_20101222\vdm5_scPsychologie_015_001_1_3_gre_field_mapping_20101222_15.img,1'};
    matlabbatch{job_counter}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
    matlabbatch{job_counter}.spm.spatial.realignunwarp.eoptions.sep = 4;
    matlabbatch{job_counter}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
    matlabbatch{job_counter}.spm.spatial.realignunwarp.eoptions.rtm = 0;
    matlabbatch{job_counter}.spm.spatial.realignunwarp.eoptions.einterp = 2;
    matlabbatch{job_counter}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
    matlabbatch{job_counter}.spm.spatial.realignunwarp.eoptions.weight = {};
    matlabbatch{job_counter}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
    matlabbatch{job_counter}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
    matlabbatch{job_counter}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
    matlabbatch{job_counter}.spm.spatial.realignunwarp.uweoptions.jm = 0;
    matlabbatch{job_counter}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
    matlabbatch{job_counter}.spm.spatial.realignunwarp.uweoptions.sot = [];
    matlabbatch{job_counter}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
    matlabbatch{job_counter}.spm.spatial.realignunwarp.uweoptions.rem = 1;
    matlabbatch{job_counter}.spm.spatial.realignunwarp.uweoptions.noi = 5;
    matlabbatch{job_counter}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
    matlabbatch{job_counter}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
    matlabbatch{job_counter}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
    matlabbatch{job_counter}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
    matlabbatch{job_counter}.spm.spatial.realignunwarp.uwroptions.mask = 1;
    matlabbatch{job_counter}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';

    job_counter = job_counter + 1;
    
    
%% ---------------- STEP 4: COREGISTRATION ---------------------- %%

    matlabbatch{job_counter}.spm.spatial.coreg.estwrite.ref ...
        = {[pwd '\' version '_' EPI_number fordner date ...
            '\ua' projekt k num2str(i) '_' version '_' EPI_number ...
            fordner date '_0009_15.img,1']};        % ANPASSEN 3/3

    matlabbatch{job_counter}.spm.spatial.coreg.estwrite.source ...
        = {[pwd '\' version '_' T1_number '_MPRAGE_' date '\' projekt ...
        k num2str(i) '_' version '_' T1_number '_MPRAGE_' date '_255.img,1']};
    matlabbatch{job_counter}.spm.spatial.coreg.estwrite.other = {''};
    matlabbatch{job_counter}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    matlabbatch{job_counter}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    matlabbatch{job_counter}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{job_counter}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    matlabbatch{job_counter}.spm.spatial.coreg.estwrite.roptions.interp = 1;
    matlabbatch{job_counter}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{job_counter}.spm.spatial.coreg.estwrite.roptions.mask = 0;
    matlabbatch{job_counter}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';

    job_counter = job_counter + 1; 

    
%% ---------------- STEP 5: SEGMENTATION ------------------------ %%    

    matlabbatch{job_counter}.spm.spatial.preproc.data...
        = {[pwd '\' version '_' T1_number '_MPRAGE_' date '\' projekt...
        k num2str(i) '_' version '_' T1_number '_MPRAGE_' date '_255.img,1']};
    matlabbatch{job_counter}.spm.spatial.preproc.output.GM = [0 0 1];
    matlabbatch{job_counter}.spm.spatial.preproc.output.WM = [0 0 1];
    matlabbatch{job_counter}.spm.spatial.preproc.output.CSF = [0 0 0];
    matlabbatch{job_counter}.spm.spatial.preproc.output.biascor = 1;
    matlabbatch{job_counter}.spm.spatial.preproc.output.cleanup = 0;
    matlabbatch{job_counter}.spm.spatial.preproc.opts.tpm ...
        = {
        'C:\spm8\tpm\csf.nii,1'                              % Anpassen dir von Matlab : phil: hab vorher 'C:\MATLAB_R2010a\spm8\tpm\csf.nii,1' 
        'C:\spm8\tpm\grey.nii,1'
        'C:\spm8\tpm\white.nii,1'
                                                            };
    matlabbatch{job_counter}.spm.spatial.preproc.opts.ngaus = [2
                                                 2
                                                 2
                                                 4];
    matlabbatch{job_counter}.spm.spatial.preproc.opts.regtype = 'mni';
    matlabbatch{job_counter}.spm.spatial.preproc.opts.warpreg = 1;
    matlabbatch{job_counter}.spm.spatial.preproc.opts.warpco = 25;
    matlabbatch{job_counter}.spm.spatial.preproc.opts.biasreg = 0.0001;
    matlabbatch{job_counter}.spm.spatial.preproc.opts.biasfwhm = 60;
    matlabbatch{job_counter}.spm.spatial.preproc.opts.samp = 3;
    matlabbatch{job_counter}.spm.spatial.preproc.opts.msk = {''};
    
    job_counter = job_counter + 1;


    
    
%% ---------------- STEP 6: NORMALISATION: WRITE ----------------- %%

    matlabbatch{job_counter}.spm.spatial.normalise.write.subj.matname ...
        = {[pwd '\' version '_' T1_number '_MPRAGE_' date '\' projekt ...
        k num2str(i) '_' version '_' T1_number '_MPRAGE_' date '_255_seg_sn.mat']};
    
    row = 1;
    
    for n = starting_image:final_image  % n gibt die Durchlaufanzahl an

        if n < 10             % if-Schleife, die f?r die richtige
            l = '000';         % Benennung des Scans sorgt
        elseif n < 100
            l = '00';
       elseif n < 1000
            l = '0';
        else 
            l = '';
        end
        
        matlabbatch{job_counter}.spm.spatial.normalise.write.subj.resample {row,1} ...
            = [pwd '\' version '_' EPI_number fordner date ...
            '\ua' projekt k num2str(i) '_' version '_' EPI_number ...
            fordner date '_' l num2str(n) '_15.img,1'];

        
        row = row + 1;

    end;
    
    matlabbatch{job_counter}.spm.spatial.normalise.write.roptions.preserve = 0;
    matlabbatch{job_counter}.spm.spatial.normalise.write.roptions.bb = [-78 -112 -50
                                                               78 76 85];
    matlabbatch{job_counter}.spm.spatial.normalise.write.roptions.vox = [2 2 2];
    matlabbatch{job_counter}.spm.spatial.normalise.write.roptions.interp = 1;
    matlabbatch{job_counter}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
    matlabbatch{job_counter}.spm.spatial.normalise.write.roptions.prefix = 'w';
    
    
    job_counter = job_counter + 1;
 

%% ---------------- STEP 7: SMOOTHING -------------------------- %%

    row = 1;
    
    for n = starting_image:final_image  % n gibt die Durchlaufanzahl an

        if n < 10             % if-Schleife, die f?r die richtige
            l = '000';         % Benennung des Scans sorgt
        elseif n < 100
            l = '00';
       elseif n < 1000
            l = '0';
        else 
            l = '';
        end
        
        matlabbatch{job_counter}.spm.spatial.smooth.data {row,1}...
            = [pwd '\' version '_' EPI_number fordner date ...
            '\wua' projekt k num2str(i) '_' version '_' EPI_number ...
            fordner date '_' l num2str(n) '_15.img,1'];
        
        
        row = row + 1;

    end;
    
    matlabbatch{job_counter}.spm.spatial.smooth.fwhm = [8 8 8];
    matlabbatch{job_counter}.spm.spatial.smooth.dtype = 0;
    matlabbatch{job_counter}.spm.spatial.smooth.prefix = 's';
    
    
    job_counter = job_counter + 1;
    
 cd ..
end;
