%% dicom2nifti(varargin)
%
% Description:
%   
%   Converts DICOM-files (.dcm) to NIfTI-files (.nii or .img/.hdr). A specified 
%   directory (dicom_dir) and its subdirectories are searched for DICOM-files. 
%   These files will then be converted to NIfTI format using SPM5 functions. 
%   The NIfTI-files will be properly named, moved to a target-directory 
%   (subject_dir) and sorted in subdirectories according to their type 
%   (anatomical, overlay, functional, or DTI).
%
% Quick start example:
% 
%   Let's say your DICOM-files are organized as follows: 
%   - c:\my_study
%     - subj_1
%       - dicom
%         - 1.2.840...141
%           - 1.2.840...424 ( 6016 *.dcm-files -> 188 functional images = run 1)
%           - 1.2.840...522 ( 9664 *.dcm-files -> 302 functional images = run 2)
%           - 1.2.840...620 ( 1008 *.dcm-files -> 24 DTI images, 42 slices each)
%           - 1.2.840...718 ( 172 *.dcm-files -> 1 anatomical image, 172 slices)
%      - subj_2
%        - dicom ...
%      - ... 
%
%   Proceed as follows:
%   1. Make sure the directory containing dicom2nifti.m is added to your 
%      Matlab path (Use File->Set Path->Add Folder).
%   2. Create a new M-file in Matlab.
%   3. Write a line of code for every subject, e.g.:
%        dicom2nifti('dicom_dir', 'c:\my_study\subj_1\dicom', 'subject_dir', 'c:\my_study\subj_1');
%        dicom2nifti('dicom_dir', 'c:\my_study\subj_2\dicom', 'subject_dir', 'c:\my_study\subj_2');
%        ...
%      However, if you use dicom2nifti for the first time, consider running only 
%      one subject and check the results before processing all your subjects. Note 
%      that the directory 'subject_dir' will be created by dicom2nifti if it 
%      doesn't exist yet.  
%   4. Save the M-file and run it (by pressing F5).
%
%   After a few hours, you'll end up with the following (specify the additional 
%   parameters in brackets to change the file-names and directory-names according 
%   to your preferences):
%   - c:\my_study
%     - subj_1              ('subject_dir')
%       - dicom             ('dicom_dir', remains unchanged)
%       - anat              ('anat_dir')
%         - anatomy.nii     ('anat_fn')
%       - dti               ('dti_dir')
%         - dti_01.nii      ('dti_prefix', 'dti_digits')   
%         - ...
%         - dti_24.nii         
%       - func              ('func_dir')
%         - run_001         ('run_dir_naming', 'run_dir_prefix', 'run_dir_digits')
%           - vol_001.nii   ('func_prefix', 'func_digits')
%           - ...
%           - vol_188.nii
%         - run_002
%           - vol_001.nii
%           - ...
%           - vol_302.nii
%
% Optional Arguments:
%
%   Arguments need to be specified as strings in the following way: 
%   dicom2nifti('parameter', 'value', 'parameter', 'value', ... )
%
%	'dicom_dir':                DICOM-directory, subdirectories are also
%                           	searched for DICOM-files. Specify it, if you 
%                               don't want to use the browser.
%   'subject_dir':              Subject-directory. Specify it, if you don't 
%                               want to use the browser. If the specified 
%                               directory doesn't exist yet, it will be 
%                               created.
%   'format':                   'nii': Single file NIfTI format (default)
%                               'img': two file (hdr+img) NIfTI format                              
%   'anat_dir':                 Specify, if you want to name your
%                               anatomy-directory different from anat.
%   'anat_fn':                  Specify, if you want to name your
%                               anatomical files different from 'anatomy'.
%   'overlay_fn':               Specify, if you want to name your overlay
%                               different from 'overlay'.
%   'func_dir':                 Specify, if you want to name your
%                               functional direcory different from func.
%   'func_prefix':              Specify, if you want to name your
%                               functional files different from
%                               'vol_*'.
%   'func_digits':              Specify, if you want to name your
%                               functional files number with a different 
%                               amount of digits than 3. 
%                               (e.g. '6' -> 'vol_000001' instead of 
%                               'vol_001').                    
%   'run_dir_naming':           Specify naming of run directories:
%                               'renumber': Run directories will be renumbered to 
%                               run_001, run_002, etc. (default). The
%                               numbering is derived from series numbers in
%                               DICOM-headers.
%                               'series_number': Run directories will be named by 
%                               series number in DICOM headers without renumbering.
%                               'series_description': Run directories will be 
%                               named by series description in DICOM headers.
%   'run_dir_prefix':           Specify, if you want to name your
%                               run-direcorties different from run_*. Note
%                               that run_dir_naming must specified as
%                               'renumber', otherwise run_dir_prefix is ignored.
%   'run_dir_digits':           Specify, if you want to number your
%                               run-directories number with a different 
%                               amount of digits from 3 (e.g. '6' -> 
%                               'run_000001' instead of 'run_001').
%                               Note that run_dir_naming must specified as 
%                               'renumber', otherwise run_dir_digits is ignored.                              
%   'dti_dir':                  Specify, if you want to name your
%                               DTI-directory different from dti.
%   'dti_prefix':               Specify, if you want to name your
%                               dti-files different from 'dti_*'.
%   'dti_digits':               Specify, if you want to name your
%                               dti-files number with a different 
%                               amount of digits than 2. 
%                               (e.g. '6' -> 'dti_000001' instead of 
%                               'dti_01').
%   'anat_slices_threshold':    Only specify, if your anatomical images are
%                               being misinterpreted as overlay or vice versa. 
%                               Images with a smaller number of slices are 
%                               considered overlay, images with a bigger 
%                               or equal number of slices are considered 
%                               anatomical.
%   'func_imgs_threshold':      Only specify, if your functional images are
%                               being misinterpreted as DTI or vice versa. 
%                               If the number of images is smaller, they are
%                               considered DTI, if the number of images is 
%                               bigger or equal they are considered
%                               functional.
%
% Note:
%
%   - dicom2nifti depends on SPM5 functions, so SPM5 must be in a directory named
%     spm5 or SPM5 and added to your matlab path. Make sure SPM5 is
%     properly updated (download latest updates from SPM homepage).
%   - While the resulting NIfTI files turn out identical (binary equal) using 
%     dicom2nifti (SPM5) and MRICro dicom conversion, the *.hdr files contain 
%     different affine rotation matrices. While MRICro (1.39) can't interpret these 
%     matrices, the difference shows using SPM5's checkreg. However, this is 
%     probably won't make any difference if you realign, coregister or normalize your 
%     images, since the affine rotation matrix is overwritten anyway.
%   - spm5batch has been tested on WinXP and Linux with Matlab 7.0 and
%     7.2. Other platforms (e.g.) MacOSX and older Matlab versions
%     may work too.
%   - All arguments (also numbers) must be specified as strings!
%     correct: dicom2nifti('func_digits', '6'); 
%     wrong: dicom2nifti('func_digits', 6);
%   - Please contact me (Adrian Imfeld) for feedback or bug-reporting.
%   - Distribute dicom2nifti as you please, but please do not distribute
%     modified versions of dicom2nifti.
%   - Thanks to Cyrill Ott and Sylvie Pantano for testing.
%
% Author:
%
%   (c) 26-Feb-2007 Adrian Imfeld
%   contact: neurotools@aimfeld.ch
%   web: www.aimfeld.ch/neurotools/neurotools.html
%
% Last updated:
%
%   30-Oct-2007, Adrian Imfeld 
% 
% Version:
%
%   dicom2nifti v1.8
%
% Version History
%
%   - v1.8: Minor tweaks and renaming of dicom2analyze to
%           dicom2nifti.
%   - v1.7: Bugfix of datestr (dicom2nifti may work on
%           Matlab 6.5 now).
%   - v1.6: First release on SPM homepage (15-Sep-2007) .

function [dcm_converted] = dicom2nifti(varargin)

version_str = 'v1.8';

%%  SPM5 check
if exist('spm','file') && ~isempty(spm('Ver','spm',1,1,1))
    if ~strcmp(spm('Ver','spm',1,1,1), 'SPM5')
        error('Wrong SPM version! Required: "SPM5" - active: "%s"!\n', spm('Ver','spm',1,1,1));
    end
else
    error('\nThe SPM5 path is not added to the Matlab search path!');
end 

%% Assign default variable values
dicom_dir = [];
subject_dir = [];
format = 'nii';
anat_dir = 'anat';
anat_fn = 'anatomy';
overlay_fn = 'overlay'; % overlay goes to anat_dir
func_dir = 'func';
func_prefix = 'vol_';
func_digits = 3;
run_dir_naming = 'renumber'; % values: 'renumber', 'series_number', 'series_description'
run_dir_prefix = 'run_';
run_dir_digits = 3;
dti_dir = 'dti';
dti_prefix = 'dti_';
dti_digits = 2;
anat_slices_threshold = 100; % If number of slices is bigger -> anatomical, else overlay
func_imgs_threshold = 65; % If number of converted images is bigger -> functional, else DTI

% Internal variables
temp_dir_name = 'd2n_temp';
dt_anat = 1; dt_overlay = 2; dt_func = 3; dt_dti = 4; dt_unknown = 5;
dti_imgs_threshold = 6;
recursive = 'no';
dcm_converted = 0;
datatype = dt_unknown;
series_description = [];

%% Override variables values by arguments
if mod(length(varargin), 2) ~= 0
    error('Wrong number of input arguments! required: (''variable name'', ''value'') ...');
end

for n=1:2:length(varargin)
    if strcmp(varargin(n), 'dicom_dir')
        dicom_dir = char(varargin(n+1));
    elseif strcmp(varargin(n), 'subject_dir')
        subject_dir = char(varargin(n+1));
    elseif strcmp(varargin(n), 'format')
        if strcmp(varargin(n+1), 'nii') || strcmp(varargin(n+1), 'img')
            format = char(varargin(n+1));
        else
            error('Invalid argument for parameter ''format''.');
        end
    elseif strcmp(varargin(n), 'anat_dir')
        anat_dir = char(varargin(n+1));
    elseif strcmp(varargin(n), 'anat_fn')
        anat_fn = char(varargin(n+1));
    elseif strcmp(varargin(n), 'overlay_fn')
        overlay_fn = char(varargin(n+1));
    elseif strcmp(varargin(n), 'func_dir')
        func_dir = char(varargin(n+1));
    elseif strcmp(varargin(n), 'func_prefix')
        func_prefix = char(varargin(n+1));
    elseif strcmp(varargin(n), 'func_digits')
        func_digits = str2num(char(varargin(n+1)));
    elseif strcmp(varargin(n), 'run_dir_naming')
        run_dir_naming = char(varargin(n+1));
    elseif strcmp(varargin(n), 'run_dir_prefix')
        run_dir_prefix = char(varargin(n+1));
    elseif strcmp(varargin(n), 'run_dir_digits')
        run_dir_digits = str2num(char(varargin(n+1)));
    elseif strcmp(varargin(n), 'dti_dir')
        dti_dir = char(varargin(n+1));
    elseif strcmp(varargin(n), 'dti_prefix')
        dti_prefix = char(varargin(n+1));
    elseif strcmp(varargin(n), 'dti_digits')
        dti_digits = str2num(char(varargin(n+1)));
    elseif strcmp(varargin(n), 'anat_slices_threshold')
        anat_slices_threshold = str2num(char(varargin(n+1)));
    elseif strcmp(varargin(n), 'func_imgs_threshold')
        func_imgs_threshold = str2num(char(varargin(n+1)));
    elseif strcmp(varargin(n), 'recursive')
        recursive = char(varargin(n+1));
    else
        error('Unknown parameter "%s", please check spelling.', char(varargin(n)));
    end
end

%% Running message
if strcmp(recursive, 'no')
    time_message(sprintf('Running dicom2nifti %s', version_str));
end

%% Check input and output directories 	
if isempty(dicom_dir)
    dicom_dir = remove_trailing_sep(spm_select(1, 'dir', 'Select directory with DICOM files'));
end
if ~exist(dicom_dir, 'dir')
	error('%s is no valid directory.', dicom_dir);
end


if isempty(subject_dir)
    subject_dir = remove_trailing_sep(spm_select(1, 'dir', 'Select subject directory for converted files'));
    if ~exist(subject_dir, 'dir')
        error('Subject directory not specified.');
    end
end
% Create subject output directory, if neccessary
if ~exist(subject_dir, 'dir') && ~mkdir(subject_dir)
	error('Could not create subject directory %s.', subject_dir);
end

%% Find DICOM-files and convert them using SPM5
disp(sprintf('\nLooking for DICOM-files in %s ...', dicom_dir));
dcmfilepattern = '*.dcm';
dicom_files = dir(fullfile(dicom_dir, dcmfilepattern));

if length(dicom_files) > 0
    
    % Create temporary directory
    temp_dir = fullfile(subject_dir, temp_dir_name);
    if exist(temp_dir, 'dir')
        rmdir(temp_dir, 's'); % delete old temporary files
    end
    if ~mkdir(temp_dir)
        error('Temporary directory %s could not be created.', temp_dir);
    end
        
    if strcmp(recursive, 'no') && length(dicom_files) < 1
        error('No %s files found in %s',dcmfilepattern, dicom_dir);
    end
    
    P = strvcat(dicom_files.name);
    P = [char(ones(size(P,1),1)*[dicom_dir, filesep]) P];

    cwd = pwd;
    if strcmp(cwd, temp_dir)
        cwd = subject_dir;
    end
    cd(temp_dir);
    
    % Open headers
    disp(sprintf('\nOpening %d DICOM-headers (can take some time) ...', length(dicom_files)));
    hdrs = spm_dicom_headers(P);

    % Convert
    disp(sprintf('\nConverting %d DICOM-files (can also take some time) ...', length(dicom_files)));
    % spm_dicom_convert(hdrs);
    spm_dicom_convert(hdrs, 'all', 'flat', format);
        
    cd(cwd); 
            
    % Determine data type (anatomical, overlay, functional, dti, or unknown)
    img_files = dir(fullfile(temp_dir, ['*.' format]));
    V = spm_vol(fullfile(temp_dir, img_files(1).name)); % read first volume

    if length(img_files) > 1
        if length(img_files) >= func_imgs_threshold   % Number of images
            datatype = dt_func;
        elseif length(img_files) >= dti_imgs_threshold
            datatype = dt_dti;
        end
    else
        if V.dim(3) >= anat_slices_threshold    % Number of slices
            datatype = dt_anat;
        else
            datatype = dt_overlay;
        end
    end
    if datatype == dt_unknown % e.g. localizer
        disp(sprintf('\nIgnoring DICOM-files in %s because data type is unknown.', dicom_dir));
        rmdir(temp_dir, 's'); 
        return; % Just warn and quit instead of error because of recursion
    end

    %% Rename converted files and move them to their target directories
    fprintf('\nOrganizing images:            ');

    for i=1:length(img_files)

        fprintf('\b\b\b\b\b\b\b\b\b\b\b%05d/%05d',i,length(img_files));
        [p fn ext] = fileparts(img_files(i).name);
        rn = fn(length(fn)-19:length(fn)-16); % get run number 
        vn = fn(length(fn)-7:length(fn)-3); % get vol number

        if datatype == dt_func                
            target_dir = fullfile(subject_dir, func_dir, rn);
            if strcmp(run_dir_naming, 'series_description')
                if ~isempty(hdrs{1}.SeriesDescription)
                    t_dir = fullfile(subject_dir, func_dir, hdrs{1}.SeriesDescription);
                    try % Series description may contain illegal caracters
                        if ~exist(t_dir, 'dir') 
                            mkdir(t_dir); 
                        end
                        target_dir = t_dir;
                    catch 
                        warning(sprintf('Directory ''%s'' can not be created. Using ''%s'' instead.', t_dir, target_dir)); 
                    end
                else
                    warning('No series description found. Run directory will be named by series number.');
                end                       
            end
            target_fn = sprintf([func_prefix, '%0', int2str(func_digits), 'd'], i);
        elseif datatype == dt_anat
            target_dir = fullfile(subject_dir, anat_dir);
            target_fn = anat_fn;
        elseif datatype == dt_overlay
            target_dir = fullfile(subject_dir, anat_dir);
            target_fn = overlay_fn;
        elseif datatype == dt_dti
            target_dir = fullfile(subject_dir, dti_dir);
            target_fn = sprintf([dti_prefix, '%0', int2str(dti_digits), 'd'], i);
        end

        if ~exist(target_dir, 'dir')
            mkdir(target_dir);
        end

        % Move images
        exts = {'.nii'};
        if strcmp(format, 'img')
            exts = {'.img' '.hdr'};
        end
        for iext=1:length(exts)
            source_ffn = fullfile(temp_dir, [fn, exts{iext}]);
            target_ffn = fullfile(target_dir, [target_fn, exts{iext}]);
            movefile(source_ffn, target_ffn);
        end
    end

    fprintf(' done.\n');

    rmdir(temp_dir, 's'); % temp_dir should be empty by now.

end % of if length(dicom_files) > 0

if datatype ~= dt_unknown
    dcm_converted = length(dicom_files);
end

%% Recursive call for subdirectories of dicom_dir
disp(sprintf('\nLooking for subdirectories ...'));
d = dir(dicom_dir);
for i=3:length(d) % Skip . and ..
    if d(i).isdir
        dcm_converted = dcm_converted + ...
            dicom2nifti('dicom_dir', fullfile(dicom_dir, d(i).name), 'subject_dir', subject_dir, ...
            'format', format, 'anat_dir', anat_dir, 'anat_fn', anat_fn, 'overlay_fn', overlay_fn, ...
            'func_dir', func_dir, 'func_prefix', func_prefix, 'func_digits', int2str(func_digits), ...
            'run_dir_naming', run_dir_naming, ...
            'run_dir_prefix', run_dir_prefix, 'run_dir_digits', int2str(run_dir_digits), ...
            'dti_dir', dti_dir, 'dti_prefix', dti_prefix, 'dti_digits', int2str(dti_digits), ...
            'anat_slices_threshold', int2str(anat_slices_threshold), ...
            'func_imgs_threshold', int2str(func_imgs_threshold), ...
            'recursive', 'yes');
    end
end

%% Renumber functional runs (after all recursive calls)
if strcmp(recursive, 'no') && strcmp(run_dir_naming, 'renumber')
    if exist(fullfile(subject_dir, func_dir), 'dir')
        disp(sprintf('\nRenumbering functional runs ...'));
        d = dir(fullfile(subject_dir, func_dir));
        for i=3:length(d) % Skip . and ..
            source = fullfile(subject_dir, func_dir, d(i).name);
            target = fullfile(subject_dir, func_dir, ...
                    sprintf([run_dir_prefix, '%0', int2str(run_dir_digits), 'd'], i-2));
            if ~strcmp(source, target)
                movefile(source, target);
            end
        end
    end
end

%% End message
if strcmp(recursive, 'no')
    disp(sprintf('\ndicom2nifti converted %d DICOM-files.\n', dcm_converted));
    time_message(sprintf('dicom2nifti %s, (c) by Adrian Imfeld.', version_str));
end

end % of main function

%%
%% Local functions
%%
%%


% Remove trailing non-alphabetic, numeric, or underscore characters at the end
% of a string. Used to remove / and \ at path-ends.
function rem = remove_trailing_sep(str)
	rem = deblank(str);
    if length(regexp(rem(length(rem)),'\w'))<1
		rem = rem(1:length(rem)-1);
	end
end

% Prints message with time report
function time_message(message)
    t_head  = sprintf('------------------------------------------------------------------------');
    t_foot  = sprintf('========================================================================');
    try tmp = datestr(now, 'HH:MM:SS - dd/mm/yyyy');
    catch tmp = datestr(now); end % Workaround for old matlab versions
    t_msg(1:length(t_foot)-length(tmp)) = ' '; 
    t_msg(1:length(message)) = message;
    t_msg = [t_msg, tmp];
    fprintf('\n');
    disp(t_head);
    disp(t_msg);
    disp(t_foot);
end
