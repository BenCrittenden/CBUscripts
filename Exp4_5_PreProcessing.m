function Exp4_5_PreProcessing

% Example script for CBU MRI workshop
% This script contains a number of steps each designed to illustrate one
% stage of the pre-processing pipeline.


% =========================================================================
% First, define do some setting up - define the names of various
% directories, and create local directories
% =========================================================================

usr_name = 'bc01'; % put your user name here
subject_number = {'CBU121075'}; % ID number for the subject we're going to analyse

% 'CBU120564','CBU120565','CBU120566','CBU120567','CBU120595','CBU120597',...
% 'CBU120602','CBU120609','CBU120612','CBU120615','CBU120618','CBU120620',...
% 'CBU120625','CBU120626','CBU120628','CBU121074','CBU121076'


%'CBU120509',,...
%','CBU120599',,'CBU120610',

nsubs =length(subject_number);                                    

n_dummy_scans = 8; 
% number of dummy scans included to allow for T1 equilibriation
% effects. These scans won't be analysed (event timings
% in the statistical model will have to be adjusted to
% take this into account)


% get the names of the directories holding the raw data we're going to use
% ------------------------------------------------------------------------
for s=1:nsubs
    csub = subject_number{s};
    raw_data = get_files('/mridata/cbu',[csub '*']); % find the subject directory
    raw_data = get_files(raw_data,'*'); % find the session directory
    raw_data = raw_data(3,:);

    struc_raw = get_files(raw_data,'*CBU_MPRAGE*'); % structural image
    EPI_raw = get_files(raw_data,'*CBU_EPI*'); % functional images
    FM_raw = get_files(raw_data,'*CBU_FieldMapping*'); % fieldmaps



    % set up local directories on your own imaging space
    % ------------------------------------------------------------------------

    % main directory
    my_data = sprintf('/imaging/%s/Experiments4_5/Nov_2012/Preprocessed_Data/%s',usr_name,csub);
    if ~exist(my_data,'dir');mkdir(my_data);end %if the directory doesn't already exist, make it
    cd(my_data)

    % sub folder for structural:
    my_struc = fullfile(my_data,'Structural');
    if ~exist(my_struc,'dir');mkdir(my_struc);end

    % As you can see, there are 3 EPI scans, and we'll keep these separate for
    % the time being. We'll create a separate directory in my_data for each
    % scan
    my_epi = cell(1,size(EPI_raw,1));
    for e=1:size(EPI_raw,1)
        my_epi{e}=fullfile(my_data,sprintf('Sess%d',e));
        if ~exist(my_epi{e},'dir');mkdir(my_epi{e});end
    end

    % There are also 2 Field Map scans, which we'll also keep separate
    fm_main = fullfile(my_data,'Fieldmaps');
    if ~exist(fm_main,'dir');mkdir(fm_main);end

    fm_names = {'raw_mag','raw_phase'};
    my_fm = cell(1,2);
    for e=1:size(FM_raw,1)
        my_fm{e}=fullfile(fm_main,fm_names{e});
        if ~exist(my_fm{e},'dir');mkdir(my_fm{e});end
    end



    % name of print file that will be used to save various graphs etc generated
    % as part of the preprocssing
    % ------------------------------------------------------------------------
    printfile = fullfile(my_data,'spm_preprocessing.ps');


    % =========================================================================






    % =========================================================================
    % Step  1 - convert the raw data to nifti, and copy it to your local
    % directory
    % =========================================================================


    % Structural ---------------------
    % --------------------------------
    cd(my_struc)

    % get the dicom files (for the MPRAGE, there's one dicom image per slice)
    files = get_files(struc_raw,'*.dcm');

    %do the conversion
    hdr = spm_dicom_headers(files);
    spm_dicom_convert(hdr);



    % Functional ---------------------
    % --------------------------------

    for e=1:size(my_epi,2)

        cd(my_epi{e})

        % get the dicom files (for the EPIs, there's one dicom image per volume)
        
        %BC added strtrim because if the file names are different lenghts
        %matlab adds spaces to make them the same length so that they fit
        %in a single matrix. When you try to get the address with the now
        %added spaces it doesn't find it because those files do not exist!
        %strtrim removes any preceding or trailing whitespace.
        files = get_files(strtrim(EPI_raw(e,:)),'*.dcm'); 

        files = files(n_dummy_scans+1:end,:); % drop the first scans as these are dummy scans
        % we won't even bother to convert them from dicom format.
        % NB - sometimes its useful to keep the very first scan. The signal is
        % much stronger, and it can give better results when we come to
        % coregister the structural to the functional data. Unless you specify
        % otherwise however, the CBU EPI sequence automatically discards the
        % first 3 scans (i.e. they don't even make it as far as dicom format),
        % so there has already been some T1 saturation by the time of the first
        % dicom image.

        % do the conversion
        hdr = spm_dicom_headers(files);
        spm_dicom_convert(hdr);
    end



    % Field Maps ---------------------
    % --------------------------------

    for e=1:size(my_fm,2)

        cd(my_fm{e})

        % get the dicom files (for the EPIs, there's one dicom image per volume)
        files = get_files(FM_raw(e,:),'*.dcm');

        % do the conversion
        hdr = spm_dicom_headers(files);
        spm_dicom_convert(hdr);
    end


    % =========================================================================






    % =========================================================================
    % Step  2 - Use tsdiffana to have a look at the EPI data and check for
    % obvious artefacts etc
    % =========================================================================


    %get files for all sessions at once
    files = get_files(char(my_epi),'f*.nii');
    tsdiffana(files,0); % pass the file names into tsdiffana
    spm_print(printfile);

    % use SPM imcalc (a very useful function that allows you to perform
    % calculations on sets of images) to generate a mean image
    spm_imcalc_ui(files,fullfile(my_epi{1},'raw_mean_img.nii'),'mean(X)',{1;0;16;1});

    % =========================================================================






    % =========================================================================
    % Step  3 - Realign the EPI data so its all in the same space
    % =========================================================================

    % don't need to get files, as we will use the same files as for tsdiffana

    % set up some options for the realignment procedure:
    %---------------------------------------------------
    options.quality = 0.9000; % quality of results (0 = worse + quicker, 1 =
    % better + slower)
    options.weight = 0; % use a weighting image? Weighting can be specified if
    % you
    options.interp = 2; % method of interpolation
    options.wrap = [0 0 0];
    options.sep = 4; % precision with which images are sampled in order to
    % determine the realignment parameters
    options.fwhm = 5; % how much to smooth data for the purpose of realigning
    % (the images themselves won't be smoothed)
    options.rtm = 0; % if 0, images will be realigned to the first image.
    %If 1, images will be realigned to first image, then a mean image will be
    % calculated, then all images will be aligned to that mean image


    % Do the realignment --------------------------------
    %----------------------------------------------------
    % now pass the names of all the files to the realignment routine - this
    % will realign the data from all sessions into the same space. The way
    % we've done it, it will realign all the images to the very first image.
    spm_realign(files,options);


    % print the realignment parameter graphs to the output file:
    spm_print(printfile)


    % Now reslice the images ----------------------------
    %----------------------------------------------------

    % At this point, the realignment is saved only in the headers of the
    % 'f*.nii' files. Now we're going to write out a set of new files that
    % incorporate this transformation.

    options.mask = 1; % mask out voxels that are outside the brain in any of
    % the images (i.e. only include voxels that are inside the brain in all images)
    options.mean = 1; % create a mean image
    options.interp = 4; % interpolation method
    options.which = 2; % which images to reslice - 2 = all


    spm_reslice(files,options);


    % =========================================================================




%     % =========================================================================
%     % Step  4 - Undistortion
%     % =========================================================================
% 
%     % get images-----------------------------------------------------
%     files = get_files(char(my_epi),'rf*.nii'); % EPI images
%     mean_img = get_files(my_epi{1},'meanf*.nii'); % mean realigned image
%     mag_img = get_files(my_fm{1},'*.nii'); % magnitude field map
%     mag_img = mag_img(1,:);
%     phase_img = get_files(my_fm{2},'*.nii'); % phase map
%     struc_img = get_files(my_struc,'s*.nii'); % structural image
% 
% 
%     % the undistortion routine uses the structural image, and tries to remove
%     % the skull using a programme called "bet" (brain extraction tool, part of
%     % the FSL suite). This works much better if the structurals are trimmed
%     % first. Normally this would be a manual step - you'd have to display the
%     % structural and decide which planes to trim - but for the sake of convenience
%     % the values have been coded in below.
%     trim_struc = trim_img(struc_img,2,190,37);
% 
% 
%     %Also... we want to use a modified version of fieldmap_undistort. This has
%     %been altered to allow us to pass in a parameter used by bet to determine
%     %what's brain and what's not. The default parameter tends to be a bit
%     %over-enthusiastic and removes large portions of prefrontal cortex
%     unix(sprintf('cp /imaging/russell/MRI_workshop/my_fieldmap_undistort_v403.m %s',my_data)); % copy the file to local directory
%     addpath(my_data); % make sure local directory is on matlab path
%     my_fieldmap_undistort_v403(mag_img,phase_img,mean_img,files,fm_main,trim_struc.fname,0.35);
% 
% 
%     % =========================================================================






    % =========================================================================
    % Step  5 - Slice Timing
    % =========================================================================

    %options:
    sliceorder = 32:-1:1; % order in which slices are acquired - default CBU
    % EPI sequence uses 32 descending slices
    refslice = 32; % which slice to align the timings to, in this case the first
    % slice to be acquired (i.e. the top slice)
    timings(1) = 2/32; % time to acquire one slice - in this case the TR (2
    % seconds) divided by the number of slices
    timings(2) = timings(1); % time to acquire the last slice - some sequences
    % include a gap between the end of the last slice and the beginning of the next volume


    for e=1:size(my_epi,2)
        % do the slice timing one session at a time - we don't want to
        % interpolate across scans from different sessions
        files = get_files(my_epi{e},'rf*.nii');
        spm_slice_timing(files, sliceorder, refslice, timings);
    end



    % this step should create a new set of images with the prefix 'af*.nii'


    % =========================================================================





    % =========================================================================
    % Step  6 - Coregister the structural to the mean undistorted EPI
    % =========================================================================


    mean_img = get_files(my_epi{1},'meanf*.nii'); % mean undistorted image
    struc_img = get_files(my_struc,'s*.nii'); % trimmed structural image

    options.cost_fun = 'nmi'; % which cost function to use - normalised mutual information
    options.sep = [4 2]; % resolution at which to sample images
    options.tol = [0.0200    0.0200    0.0200    0.0010    0.0010    0.0010 ...
        0.0100    0.0100 0.0100    0.0010    0.0010    0.0010]; % tolerance for parameters
    options.fwhm = [7 7]; % degree of smoothing to apply to images before registration

    x=spm_coreg(mean_img,struc_img,options); % find the coreg parameters

    % convert the coreg parameters into an affine transformation matrix
    M  = inv(spm_matrix(x));
    MM = zeros(4,4,1);
    MM(:,:,1) = spm_get_space(struc_img);

    % modify the header of the structural image
    spm_get_space(struc_img, M*MM(:,:,1));

    % print the results screen
    spm_print(printfile);



    % =========================================================================




    % =========================================================================
    % Step  7 - Normalise the structural
    % =========================================================================
    %
    % % The original method of doing this was to manually trim and skull strip
    % the structural (using trim_img and bet), then to match the template using
    % the whole image. The new method, which we're going to use here, is more
    % automatic, and involves segmenting the image into white and grey matter
    % first, then normalising these to tissue specific templates. This avoids
    % the need for skull stripping.

    % It does however benefit from a 2 pass procedure... The first pass doesn't
    % try to segment the image, it just corrects any bias present in the image
    % - i.e. any systematic difference in signal between different parts of the
    % brain. This is necessary as the MPRAGE images tend to be darker at the
    % front than the back


    struc_img = get_files(my_struc,'s*.nii'); % trimmed structural image


    %%%%%%%% 1st pass:
    % -------------------------------------------------------------------------
    estopts.regtype='';                     % turn off affine registration
    out = spm_preproc(struc_img,estopts);   % estimate bias field
    sn = spm_prep2sn(out);                  % convert to a transformation matrix

    writeopts.biascor = 1;                  % only write out attenuation corrected image
    writeopts.GM  = [0 0 0];                % turn off everything else...
    writeopts.WM  = [0 0 0];
    writeopts.CSF = [0 0 0];
    writeopts.cleanup = 0;
    spm_preproc_write(sn,writeopts);        % write bias corrected image (prepends 'm' suffix)



    %%%%%%%% 2nd pass using attenuation corrected image
    % -------------------------------------------------------------------------
    struc_img = get_files(my_struc,'ms*.nii'); % corrected structural image

    estopts.regtype='mni';    % turn on affine again
    out = spm_preproc(struc_img,estopts);       % estimate normalisation parameters
    [sn,isn] = spm_prep2sn(out);                % convert to matrix

    % write out GM and WM native + unmod normalised
    writeopts.biascor = 1;
    writeopts.GM  = [0 1 1];
    writeopts.WM  = [0 1 1];
    writeopts.CSF = [0 0 0];
    writeopts.cleanup = 0;
    spm_preproc_write(sn,writeopts);

    % save normalisation parametrs to a matrix file - these will be used at the
    % next stage to normalise the functional data. An inverse matrix file is
    % also created, which is useful if you want to "un-normalise" anything  -
    % e.g. regions of interest that are defined in template space.
    [pth fle]=fileparts(struc_img);
    matname = fullfile(pth,[fle '_seg_sn.mat']);
    invmatname = fullfile(pth,[fle '_seg_inv_sn.mat']);
    savefields(matname,sn);
    savefields(invmatname,isn);

    spm_write_sn(struc_img,matname); % write out normalised structural - this
    % is only really to check that the normalisation has worked, its not used
    % in any further analyses, so its only written out at fairly low resolution.




    %%%%%%%% Display the results
    % -------------------------------------------------------------------------
    figure(spm_figure('FindWin'));
    def.temp = '/imaging/local/spm/spm5/templates/T1.nii';

    imgs = char('/imaging/local/spm/spm5/templates/T1.nii',...  % T1 template
        struc_img,...                                           % Un-normalised structural
        get_files(my_struc,'wms*.nii'),...                   % Normalised structural
        get_files(my_struc,'c1m*.nii'));                        % Un-normalised grey matter

    imgs = spm_vol(imgs);
    spm_check_registration(imgs); % display the images

    ann1=annotation('textbox',[.1 .891 .3 .025],'HorizontalAlignment','center','Color','r','String','T1 template');
    ann2=annotation('textbox',[.6 .891 .3 .025],'HorizontalAlignment','center','Color','r','String','Native T1');
    ann3=annotation('textbox',[.1 .413 .3 .025],'HorizontalAlignment','center','Color','r','String','Normalised T1');
    ann4=annotation('textbox',[.6 .413 .3 .025],'HorizontalAlignment','center','Color','r','String','Native segmented grey matter');

    spm_print(printfile);

    delete(ann1); delete(ann2); delete(ann3); delete(ann4); f=figure(spm_figure('FindWin')); clf(f);


    % =========================================================================





    % =========================================================================
    % Step  8 - Apply the normalisation parameters to the EPI images
    % =========================================================================

    options.bb = [  -78  -112   -50; 78    76    85];   % = bounding box = the range of
    % co-ordinates (in mm) to include in the image
    options.vox = [3 3 3];                              % size of voxels to use in the normalised images
    options.interp = 1;                                 % interpolation method
    options.wrap = [0 0 0];                             % wrap edges?
    options.preserve = 0;                               % preserve voxel concentrations? (mainly for VBM -
    % see spm_write_sn for more details)


    files = get_files(char(my_epi),'arf*.nii'); % Undistorted EPIs
    files = char(files, get_files(my_epi{1},'meanf*.nii')); % Add mean undistorted EPI

    spm_write_sn(files,matname,options);


    % =========================================================================





    % =========================================================================
    % Step  9 - Smooth to the EPI images
    % =========================================================================

    files = get_files(char(my_epi),'warf*.nii'); % EPI images
    files = char(files,get_files(my_epi{1},'wmeanf*.nii')); % add mean undistorted EPI

    FWHM = [8 8 8]; % amount of smoothing to apply - fwhm of smoothing kernel in [x,y,z] in mm


    % Have to loop this manually as spm_smooth only does one image at a time...
    n = size(files,1);
    spm_progress_bar('Init',n,'Smoothing','Volumes Complete');

    for i = 1:n
        cimg = deblank(files(i,:)); % current image
        [pth,fle,ext] = fileparts(cimg);
        simg = fullfile(pth,['s' fle ext]); % create output file name - prepend 's' suffix
        spm_smooth(cimg,simg,FWHM); % do the smooth
        spm_progress_bar('Set',i); % update the progress bar
    end
    spm_progress_bar('Clear');

end

% =========================================================================







% =========================================================================
% =========================================================================
% Subfunctions
% =========================================================================
% =========================================================================


% =========================================================================
function files = get_files(direc, filt)
% =========================================================================
% return a list of files
% filt = filter string
% direc = cell array of directory names

files = [];
for d=1:size(direc,1) % loop through each EPI session
    tmp = dir(fullfile(direc(d,:),filt)); % find all files matching f*.nii
    tmp = [repmat([direc(d,:) filesep],size(tmp,1),1) char(tmp.name)]; % build the full path name for these files
    files = char(files,tmp);
end

files = files(~all(files'==' ')',:);

return



% =========================================================================
function savefields(fnam,p)
% =========================================================================

if length(p)>1, error('Can''t save fields.'); end;
fn = fieldnames(p);
if numel(fn)==0, return; end;
for i=1:length(fn),
    eval([fn{i} '= p.' fn{i} ';']);
end;
if str2double(version('-release'))>=14,
    save(fnam,'-V6',fn{:});
else
    save(fnam,fn{:});
end;

return;





%setenv('FSLDIR','/imaging/local/linux/bin/fsl-3.3.11');
%setenv('PATH',['/imaging/local/linux/bin/fsl-3.3.11/bin:' getenv('PATH')])