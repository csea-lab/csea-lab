

job_counter = 1;    % zählt die Spalten, also "Jobs" durch
n = 1;              % Nummer für die Bilder
row = 1;            % zählt die Zeilen, wenn mehrere Scans angegeben werden müssen

%ANPASSEN 1/3 Anfang
starting_image = 9;
final_image = 500;
pordner = 'E:\fMRI_DATEN\Psychologie_017';
projekt = 'Psychologie_017_';
fordner = '_fmri_pain_II_';
FLordner = '\FirstLevel\vp017_';
logbegin = '\log_feils_fmri_pain_II\Vp_15_';
%ANPASSEN 1/3 Ende

%start_participant = input(['Wo geht' char(39) 's los? >> ']); ...
    % char(39) = Apostroph wird als String herausgegeben
%final_participant = input(['Wo hört' char(39) 's auf? >> ']);

vp = input ('Welche VPn sollen rein?');

n_vp = size(vp,2);

z = 1; 

for z = 1:n_vp
       
    i = vp(z);
        % i ist die Variable für die Versuchspersonen

    if i < 10
        k = '00';
    elseif i < 100
        k = '0';
    else
        k = '';
    end

     
    
    %% ---------------- STEP 2: fMRI MODEL SPECIFICATION ------------------------ %%

    mkdir([pordner FLordner k num2str(i)]);
    
matlabbatch{job_counter}.spm.stats.fmri_spec.dir = {[pordner FLordner k num2str(i)]};
matlabbatch{job_counter}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{job_counter}.spm.stats.fmri_spec.timing.RT = 2.5;
matlabbatch{job_counter}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{job_counter}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

    new_directory = [pordner '\' projekt k num2str(i) '\'];
    
    cd (new_directory);

%ANPASSEN 2/2 Anfang
    EPI = dir('*fmri_pain_II*'); 
    if EPI(1).name(3) == '1' 
        date = EPI(1).name(19:end);     % anpassen, whsl. 2 stellen nach hinten
    else 
        date = EPI(1).name(18:end);
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
    
row = 1;
    
    for n = starting_image:final_image  % n gibt die Durchlaufanzahl an

        if n < 10             % if-Schleife, die für die richtige
            l = '00';         % Benennung des Scans sorgt
        elseif n < 100
            l = '0';
        else 
            l = '';
        end
       
        matlabbatch{job_counter}.spm.stats.fmri_spec.sess.scans{row,1}...
            = [pordner '\' projekt k num2str(i) '\' version '_' EPI_number fordner date ...
            '\swua' projekt k num2str(i) '_' version '_' EPI_number ...
            fordner date '_0' l num2str(n) '_15.img,1'];

        row = row + 1;

    end; 

matlabbatch{job_counter}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {});
matlabbatch{job_counter}.spm.stats.fmri_spec.sess.multi = {[pordner logbegin k num2str(i) '_trials_ons_dur_nam.mat']};
matlabbatch{job_counter}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
% Anpassen: bei 8 dummy scan ist es hier die 9
matlabbatch{job_counter}.spm.stats.fmri_spec.sess.multi_reg = {[pordner '\' projekt k num2str(i) '\' version '_' EPI_number fordner date '\rp_a' projekt k num2str(i) '_' version '_' EPI_number ...
            fordner date '_0009_15.txt']};
matlabbatch{job_counter}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{job_counter}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{job_counter}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{job_counter}.spm.stats.fmri_spec.volt = 1;
matlabbatch{job_counter}.spm.stats.fmri_spec.global = 'None';
matlabbatch{job_counter}.spm.stats.fmri_spec.mask = {''};
matlabbatch{job_counter}.spm.stats.fmri_spec.cvi = 'AR(1)';

job_counter = job_counter + 1;

%% ---------------- STEP 3: fMRI MODEL ESTIMATION ------------------ %%

  
matlabbatch{job_counter}.spm.stats.fmri_est.spmmat(1) = {[pordner FLordner k num2str(i) '\SPM.mat']};
matlabbatch{job_counter}.spm.stats.fmri_est.method.Classical = 1;

job_counter = job_counter + 1;

%% ---------------- STEP 4: CONTRAST MANAGER ------------------ %%

matlabbatch{job_counter}.spm.stats.con.spmmat(1) = {[pordner FLordner k num2str(i) '\SPM.mat']};
%ANPASSEN 3/3 Anfang  //man schaue auf den jobcounter...

matlabbatch{job_counter}.spm.stats.con.consess{1}.tcon.name = 'n_f';
matlabbatch{job_counter}.spm.stats.con.consess{1}.tcon.convec = [1 0 0 0 0 0 0 0 0 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{2}.tcon.name = 'l_f';
matlabbatch{job_counter}.spm.stats.con.consess{2}.tcon.convec = [0 1 0 0 0 0 0 0 0 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{3}.tcon.name = 'h_f';
matlabbatch{job_counter}.spm.stats.con.consess{3}.tcon.convec = [0 0 1 0 0 0 0 0 0 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{3}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{4}.tcon.name = 'n_s';
matlabbatch{job_counter}.spm.stats.con.consess{4}.tcon.convec = [0 0 0 1 0 0 0 0 0 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{5}.tcon.name = 'l_s';
matlabbatch{job_counter}.spm.stats.con.consess{5}.tcon.convec = [0 0 0 0 1 0 0 0 0 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{5}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{6}.tcon.name = 'h_s';
matlabbatch{job_counter}.spm.stats.con.consess{6}.tcon.convec = [0 0 0 0 0 1 0 0 0 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{6}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{7}.tcon.name = 'On_l_f';
matlabbatch{job_counter}.spm.stats.con.consess{7}.tcon.convec = [0 0 0 0 0 0 1 0 0 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{7}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{8}.tcon.name = 'On_h_f';
matlabbatch{job_counter}.spm.stats.con.consess{8}.tcon.convec = [0 0 0 0 0 0 0 1 0 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{8}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{9}.tcon.name = 'On_l_s';
matlabbatch{job_counter}.spm.stats.con.consess{9}.tcon.convec = [0 0 0 0 0 0 0 0 1 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{9}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{10}.tcon.name = 'On_h_s';
matlabbatch{job_counter}.spm.stats.con.consess{10}.tcon.convec = [0 0 0 0 0 0 0 0 0 1 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{10}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{11}.tcon.name = 'fear>safe';
matlabbatch{job_counter}.spm.stats.con.consess{11}.tcon.convec = [1 1 1 -1 -1 -1 0 0 0 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{11}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{12}.tcon.name = 'high>low_onset';
matlabbatch{job_counter}.spm.stats.con.consess{12}.tcon.convec = [0 0 0 0 0 0 -1 1 -1 1 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{12}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{13}.tcon.name = 'high_fear>high_safe_onset';
matlabbatch{job_counter}.spm.stats.con.consess{13}.tcon.convec = [0 0 0 0 0 0 0 1 0 -1 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{13}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{14}.tcon.name = 'low_fear>low_safe_onset';
matlabbatch{job_counter}.spm.stats.con.consess{14}.tcon.convec = [0 0 0 0 0 0 1 0 -1 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{14}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{15}.tcon.name = 'no_fear>no_safe';
matlabbatch{job_counter}.spm.stats.con.consess{15}.tcon.convec = [1 0 0 -1 0 0 0 0 0 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{15}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{16}.tcon.name = 'high>baseline_onset';
matlabbatch{job_counter}.spm.stats.con.consess{16}.tcon.convec = [0 0 0 0 0 0 0 0.5 0 0.5 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{16}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{17}.tcon.name = 'low>baseline_onset';
matlabbatch{job_counter}.spm.stats.con.consess{17}.tcon.convec = [0 0 0 0 0 0 0.5 0 0.5 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{17}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{18}.tcon.name = 'fear>baseline';
matlabbatch{job_counter}.spm.stats.con.consess{18}.tcon.convec = [1 1 1 0 0 0 0 0 0 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{18}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{19}.tcon.name = 'safe>baseline';
matlabbatch{job_counter}.spm.stats.con.consess{19}.tcon.convec = [0 0 0 1 1 1 0 0 0 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{19}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{20}.tcon.name = 'fear_h_l>safe_h_l';
matlabbatch{job_counter}.spm.stats.con.consess{20}.tcon.convec = [0 1 1 0 -1 -1 0 0 0 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{20}.tcon.sessrep = 'none';


matlabbatch{job_counter}.spm.stats.con.consess{21}.tcon.name = 'P_On_l_f';
matlabbatch{job_counter}.spm.stats.con.consess{21}.tcon.convec = [0 0 0 0 0 0 0 0 0 0 1 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{21}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{22}.tcon.name = 'P_On_h_f';
matlabbatch{job_counter}.spm.stats.con.consess{22}.tcon.convec = [0 0 0 0 0 0 0 0 0 0 0 1 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{22}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{23}.tcon.name = 'P_On_l_s';
matlabbatch{job_counter}.spm.stats.con.consess{23}.tcon.convec = [0 0 0 0 0 0 0 0 0 0 0 0 1 0];
matlabbatch{job_counter}.spm.stats.con.consess{23}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{24}.tcon.name = 'P_On_h_s';
matlabbatch{job_counter}.spm.stats.con.consess{24}.tcon.convec = [0 0 0 0 0 0 0 0 0 0 0 0 0 1];
matlabbatch{job_counter}.spm.stats.con.consess{24}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{25}.tcon.name = 'P_On_h_f >P_On_h_s';
matlabbatch{job_counter}.spm.stats.con.consess{25}.tcon.convec = [0 0 0 0 0 0 0 0 0 0 0 1 0 -1];
matlabbatch{job_counter}.spm.stats.con.consess{25}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{26}.tcon.name = 'P_On_l_f >P_On_l_s';
matlabbatch{job_counter}.spm.stats.con.consess{26}.tcon.convec = [0 0 0 0 0 0 0 0 0 0 1 0 -1 0];
matlabbatch{job_counter}.spm.stats.con.consess{26}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{27}.tcon.name = 'P_On_fear >P_On_safe';
matlabbatch{job_counter}.spm.stats.con.consess{27}.tcon.convec = [0 0 0 0 0 0 0 0 0 0 1 1 -1 -1];
matlabbatch{job_counter}.spm.stats.con.consess{27}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{28}.tcon.name = 'P_On_High >P_On_Low';
matlabbatch{job_counter}.spm.stats.con.consess{28}.tcon.convec = [0 0 0 0 0 0 0 0 0 0 -1 1 -1 1];
matlabbatch{job_counter}.spm.stats.con.consess{28}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{29}.tcon.name = 'P_und_On_h_f >P_und_On_h_s';
matlabbatch{job_counter}.spm.stats.con.consess{29}.tcon.convec = [0 0 1 0 0 -1 0 0 0 0 0 1 0 -1];
matlabbatch{job_counter}.spm.stats.con.consess{29}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{30}.tcon.name = 'fear>baseline_2';
matlabbatch{job_counter}.spm.stats.con.consess{30}.tcon.convec = [0 0.5 0.5 0 0 0 0 0 0 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{30}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{31}.tcon.name = 'safe>baseline_2';
matlabbatch{job_counter}.spm.stats.con.consess{31}.tcon.convec = [0 0 0 0 0.5 0.5 0 0 0 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{31}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{32}.tcon.name = 'fear>safe_2';
matlabbatch{job_counter}.spm.stats.con.consess{32}.tcon.convec = [0 1 1 0 -1 -1 0 0 0 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{32}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.consess{33}.tcon.name = 'safe>fear_2';
matlabbatch{job_counter}.spm.stats.con.consess{33}.tcon.convec = [0 -1 -1 0 1 1 0 0 0 0 0 0 0 0];
matlabbatch{job_counter}.spm.stats.con.consess{33}.tcon.sessrep = 'none';

matlabbatch{job_counter}.spm.stats.con.delete = 0;


%ANPASSEN 3/3 Ende
matlabbatch{job_counter}.spm.stats.con.delete = 0;

job_counter = job_counter + 1;


end;
