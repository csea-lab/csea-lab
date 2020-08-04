% log_roi_batch(img_files, roi_files, log_file, varargin)
%
% Description:
%
%   Creates tables of values such as mean or standard deviation for 
%   regions of interest (ROIs) or counts voxels within a given range. 
%   A set of p ROIs is applied to a set of q image files in order to 
%   calculate r values of interest, resulting in p*q*r values to be 
%   logged. Voxel exclusion criteria can be specified, which can also 
%   be used to count the number of included or excluded voxels within 
%   a given range.
%   All images and ROIs must be of the same dimensions, voxel size, 
%   and orientation. If need be, reslice your images before running 
%   this script using e.g. SPM5's realign->reslice (images 2..n).
%
% Arguments:
%
%   Arguments need to be specified as strings in the following way: 
%   log_roi_batch('parameter', 'value', 'parameter', 'value', ... )
%
%   'img_files':    Set of data images (*.img or *.nii, cell array of 
%                   strings).
%   'roi_files':    Set of ROI images (*.img or *.nii, cell array of 
%                   strings). Values > 0 indicate ROI area.
%   'log_file':     Name of log file (string). If the file already 
%                   exists, a new line will be appended.
%
% Optional Arguments:
%
%   'subject':      Subject name (string). Each call of log_roi_batch 
%                   creates a new line in the log-file. This name will be
%                   written in the subject column. Default: 'unknown'.
%   'ignore':       Value (int) which indicates voxels of no interest 
%                   (e.g. non-brain voxels). Default: 0.
%   'low_cutoff':   Specify, if you want to exclude voxels with values 
%                   below a low_cutoff value from logging. 
%                   Default: [] (not set).
%   'high_cutoff':  Specify, if you want to exclude voxels with values 
%                   above a high_cutoff value from logging.
%                   Default: [] (not set).
%   'log':          Specify your values of interest, i.e. what 
%                   information you want to have in your log-file 
%                   (cell array of strings). Possible values:
%                   'mean': The mean value of a ROI.
%                   'std': The standard deviation of a ROI.
%                   'included': The number of voxels included (not 
%                               ignored or cut off).
%                   'ignored': Number of ignored voxels in a ROI.
%                   'below': Number of voxels below the low_cutoff 
%                            value  in a ROI.
%                   'above': Number of voxels above the high_cutoff 
%                            value in a ROI.
%                   Default: {'mean', 'std', 'included', 'ignored'}
%   'format':       The format of logged values. Specifiy '%E' for
%                   scientific notation. Default: '%f'
%
% Note:
%
%   - log_roi_batch depends on SPM5 functions, so SPM5 must be added 
%     to your matlab path.
%
% Example:
%
%   Let's say you want to do DTI ROI-analysis of mean fractional 
%   anisotropy (FA) of the left and the right corticospinal tracts 
%   in MNI space. You have calculated FA with two different 
%   formulas (f1 and f2) for two subjects (s1 and s2) and you'd like 
%   to check the difference between the results of the formulas. So 
%   you have anisotropy images for s1 and s2 with formulas f1 and f2
%   (c:\s1_FA_f1.img,hdr; c:\s1_FA_f2.img,hdr; c:\s2_FA_f1.img,hdr;
%   c:\s2_FA_f2.img,hdr).
%   You have two ROIs (c:\left_CST.img,hdr and c:\right_CST.img,hdr) 
%   which mark the left (1st ROI) and the right (2nd ROI) corticospinal 
%   tract with ones, and the rest with zeros in MNI space. 
%   All images and ROIs have been resliced to the same dimensions, voxel 
%   size, and orientation with SPM5's realign->reslice (images 2..n).
%   Because you're only interested in white matter, you want to exclude 
%   any grey matter voxels in the ROIs from averaging. A voxel is 
%   considered to be grey matter if FA < 0.2. You want the mean FA 
%   of both subjects for the left and the right corticospinal tract,
%   the number of non-brain voxels in the FA images marked by the ROIs
%   (we hope that's gonna be zero), and the number of voxels in the 
%   ROI with FA < 0.2 (should be small if the ROIs are good). So we go 
%   with the following two calls (one for each subject) which you 
%   have typed in a new *.m file:
%
%       log_roi_batch({'c:\s1_FA_f1.img', 'c:\s1_FA_f2.img'}, ...
%                     {'c:\left_CST.img', 'c:\right_CST.img'}, ...
%                      'c:\CST_logfile.txt', 'subject', 's1', ...
%                      'low_cutoff', 0.2, ...
%                      'log', {'mean', 'ignored', 'below'});
%       log_roi_batch({'c:\s2_FA_f1.img', 'c:\s2_FA_f2.img'}, ...
%                     {'c:\left_CST.img', 'c:\right_CST.img'}, ...
%                      'c:\CST_logfile.txt', 'subject', 's2', ...
%                      'low_cutoff', 0.2, ...
%                      'log', {'mean', 'ignored', 'below'});
%
%   After saving the *.m file and executing it with F5, we get the 
%   results from c:\CST_logfile.txt which contains a header with column 
%   names and a line for each subject.
%
% Author:
%
%   (c) 29-Oct-2007 Adrian Imfeld
%   contact: neurotools@aimfeld.ch
%   web: www.aimfeld.ch/neurotools/neurotools.html
%
% Last updated:
%
%   22-Oct-2007, Adrian Imfeld 
% 
% Version:
%
%   log_roi_batch v1.1
%

function log_roi_batch(img_files, roi_files, log_file, varargin)

version_str = 'v1.1';

%% Start message
time_message(sprintf('Running log_roi_batch %s', version_str));

%%  SPM5 check
if exist('spm','file') && ~isempty(spm('Ver','spm',1,1,1))
    if ~strcmp(spm('Ver','spm',1,1,1), 'SPM5')
        error('Wrong SPM version! Required: "SPM5" - active: "%s"!\n', spm('Ver','spm',1,1,1));
    end
else
    error('\nThe SPM5 path is not added to the Matlab search path!');
end 

%% Default parameters
subject = [];
ignore = 0; % voxels with this value are excluded (non-brain voxels
low_cutoff = [];
high_cutoff = [];
log = {'mean', 'std', 'included', 'ignored'}; % values: mean, std, included, ignored, below, above
format = '%f'; % alternative: e.g. %E for scientific notation

%% Override default parameters
if mod(length(varargin), 2) ~= 0
    error('Wrong number of input arguments! required: (''variable name'', ''value'') ...');
end

for n=1:2:length(varargin)
    if strcmp(varargin(n), 'subject')
        subject = char(varargin(n+1));
    elseif strcmp(varargin(n), 'ignore')
        ignore = varargin{n+1};
    elseif strcmp(varargin(n), 'low_cutoff')
        low_cutoff = varargin{n+1};
    elseif strcmp(varargin(n), 'high_cutoff')
        high_cutoff = varargin{n+1};
    elseif strcmp(varargin(n), 'log')
        log = varargin{n+1};
    elseif strcmp(varargin(n), 'format')
        format = char(varargin(n+1));
    else
        error('Unknown parameter "%s", please check spelling.', char(varargin(n)));
    end
end


% Read image and roi headers
V_img = spm_vol(strvcat(img_files));
V_roi = spm_vol(strvcat(roi_files));

% Image dimension, orientation and voxel size checks (spm_read_vols.m)
V_both = [V_img; V_roi];
if length(V_both)>1 & any(any(diff(cat(1,V_both.dim),1,1),1))
	error('Images don''t all have the same dimensions. Please reslice.'), end
if any(any(any(diff(cat(3,V_both.mat),1,3),3)))
	error('Images don''t all have same orientation & voxel size. Please reslice.'), end

% Read images and rois
[Y_img, XYZ_img] = spm_read_vols(V_img);
[Y_roi, XYZ_roi] = spm_read_vols(V_roi);

cnt = 1;
if ~isempty(subject)
    data(1, cnt) = {'subject'};
    data(2, cnt) = {subject}; 
    data(3, cnt) = {'%s'};
    cnt = cnt + 1;
end

for r=1:length(roi_files)
    [roi_path, roi_file, roi_ext] = fileparts(roi_files{r});
    for i=1:length(img_files)
        image = Y_img(:,:,:,i);
        [img_path, img_file, img_ext] = fileparts(img_files{i});
        
        ind = find(Y_roi(:,:,:,r)); % indices of roi marked voxels (value > 0)

        % Ignore (non-brain) voxels
        ind_i = ind(find(image(ind) ~= ignore)); % indices with exclusion of ignore-valued voxels
        ind_il = ind_i; % indices with exclusion of below-low-cutoff values
        if ~isempty(low_cutoff)
            ind_il =  ind_i(find(image(ind_i) >= low_cutoff));
        end
        ind_ilh = ind_il; % indices with exclusion of values above-high-cutoff values
        if ~isempty(high_cutoff)
            ind_ilh =  ind_il(find(image(ind_il) <= high_cutoff));
        end

        % values: mean, std, included, ignored, below, above
        
        % Calculate values
        for log_entry=1:length(log)
            if strcmp(log{log_entry}, 'mean')
                data(1, cnt) = {[roi_file '_' img_file '_mean']};
                data(2, cnt) = {mean(image(ind_ilh))}; 
                data(3, cnt) = {format};
                cnt = cnt + 1;
            end
            if strcmp(log{log_entry}, 'std')
                data(1, cnt) = {[roi_file '_' img_file '_std']};
                data(2, cnt) = {std(image(ind_ilh))}; 
                data(3, cnt) = {format};
                cnt = cnt + 1;
            end
            if strcmp(log{log_entry}, 'included')
                data(1, cnt) = {[roi_file '_' img_file '_included']};
                data(2, cnt) = {length(ind_ilh)}; 
                data(3, cnt) = {'%d'}; % not dependent on the format parameter
                cnt = cnt + 1;
            end
            if strcmp(log{log_entry}, 'ignored')
                data(1, cnt) = {[roi_file '_' img_file '_ignored']};
                data(2, cnt) = {length(ind) - length(ind_i)}; 
                data(3, cnt) = {'%d'}; 
                cnt = cnt + 1;
            end
            if strcmp(log{log_entry}, 'below') % number of below low-cutoff voxels
                data(1, cnt) = {[roi_file '_' img_file '_below']};
                data(2, cnt) = {length(ind_i) - length(ind_il)}; 
                data(3, cnt) = {'%d'}; 
                cnt = cnt + 1;
            end
            if strcmp(log{log_entry}, 'above') % number of above high-cutoff voxels
                data(1, cnt) = {[roi_file '_' img_file '_above']};
                data(2, cnt) = {length(ind_il) - length(ind_ilh)}; 
                data(3, cnt) = {'%d'}; 
                cnt = cnt + 1;
            end
        end % for log entry
    end % for image
end % for roi

%% Write logfile
writeheader = ~exist(log_file, 'file');
fid = fopen(log_file, 'a');
cols = size(data, 2); % number of columns in logfile
if writeheader
    for i=1:cols-1
        fprintf(fid, '%s\t ', data{1, i});
    end
    fprintf(fid, '%s', data{1, cols});
end

fprintf(fid, ['\n' data{3, 1} '\t '], data{2, 1}); % first entry on new line (\n)
for i=2:cols - 1
    fprintf(fid, [data{3, i} '\t '], data{2, i});
end
fprintf(fid, data{3,  cols}, data{2, cols}); % last entry without tab at the end (\t)

fclose(fid);

time_message(sprintf('log_roi_batch %s done, (c) by Adrian Imfeld.', version_str));

end


%%
%% Local functions
%%
%%

% Prints message with time report
function time_message(message)
    t_head  = sprintf('------------------------------------------------------------------------');
    t_foot  = sprintf('========================================================================');
    tmp = datestr(now, 'HH:MM:SS - dd/mm/yyyy');
    t_msg(1:length(t_foot)-length(tmp)) = ' '; 
    t_msg(1:length(message)) = message;
    t_msg = [t_msg, tmp];
    fprintf('\n');
    disp(t_head);
    disp(t_msg);
    disp(t_foot);
end