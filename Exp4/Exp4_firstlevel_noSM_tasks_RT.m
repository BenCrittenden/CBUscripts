%-----------------------------------------------------------------------
%Design specific parameters
%-----------------------------------------------------------------------

clear
spm_defaults; 
addpath('/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4');

% Location of the data which has already been preprocessed:
data_dir = '/imaging/bc01/Experiments4_5/Nov_2012/Preprocessed_Data';

% Location of the behavioural data from the scan, such as reaction times,
% accuracy
stats_dir = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/Behavioural_Data';

res_dir = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/NonSmoothed/noSM_Tasks_RT';
if exist(res_dir,'dir')~=7;mkdir(res_dir);end

%Around line 171 is the name of the function called to extract events from
%the behavioural file.


% rootdir = '/imaging/aw02/AffixIDfmri'; 
% resdir = fullfile(rootdir,'behav_data');
% resmat = fullfile(resdir,'AllSs.mat'); %data structure = res

%load (resmat);

%subject directory names
%for s = 1:length(res.subs)
%    subs{s} = res.subs{s};
%end

subs={'CBU120564','CBU120565','CBU120566','CBU120567','CBU120595',...
      'CBU120597','CBU120602','CBU120609','CBU120612','CBU120615',...
      'CBU120618','CBU120620','CBU120625','CBU120626','CBU120628',...
      'CBU121074','CBU121075','CBU121076'};



nsubs = length(subs);

%number of runs
nsess = 4;

%ntot = nsubs*nsess;

%condnames = {'Stimulus showing'}; %going to be compared to implicit baseline, which includes visual cues, fixation cross and trial onset cue (coloured fixation cross)

%Conditions: 1-6 are for the tasks, 7-12 are for the RTs.
 for StimType = 1:12
     condnames{StimType} = ['Condition' num2str(StimType)];
 end
 
 

ncond = length(condnames);
TR = 2.0;

%where the subject directories are
dataroot = data_dir; %fullfile(rootdir, 'singlesubs_data'); 

% hpf (high pass filter) value. The cut-off frequency at which low-frequency
% signal is removed. Low freq's are typically noise within the signal, so
% it's good to remove them.
hpf = 128;

%Are we including movement parameters? 1 if yes.
incmoves = 0;

% if incmoves == 0;
%     res_dir = [res_dir '_nomvs'];
% elseif incmoves == 1;
%     res_dir = [res_dir '_wmvs'];disp('including move params');
% end

%Set up filter to grab smoothed normalised images in specified folder
%changed to (hopefully) use un-normalised, unsmoothed images.
%For smoothed normalised (eg for univariate) use imgfilt = '^s.*\.nii$'
% imgfilt = '^s.*\.nii$';
imgfilt = '^w.*\.nii$';

%if no preprocessing (raw files):
%imgfilt = '^f.*\.nii$';

%Next two lines for movement parameters if including as cov of no interest
movefilt = '^rp_.*\.txt$';
mnames = {'x_trans' 'y_trans' 'z_trans' 'x_rot' 'y_rot' 'z_rot'};

%-----------------------------------------------------------------------
%Design setup
%-----------------------------------------------------------------------

% basis functions and timing parameters
%---------------------------------------------------------------------------
% OPTIONS:'hrf'
%         'hrf (with time derivative)'
%         'hrf (with time and dispersion derivatives)'
%         'Fourier set'
%         'Fourier set (Hanning)'
%         'Gamma functions'
%         'Finite Impulse Response'
%---------------------------------------------------------------------------

xBF.name       = 'hrf';
xBF.length     = 32;                % length in seconds of the post stimulus lag of the basis function (hrf)
xBF.order      = 1;                 % order of basis set - how many basis function
xBF.T          = 32;                % number of time bins per scan (24 slices with quiet EPI)
xBF.T0         = 1;                 % first time bin - depends on how you've done your aa

% (I think this means the slice number that occurs at time 1 (if in scans),
% 0 if in secs)
%- should be set to be the same as
%reference slice (ie 1st / "top" slice if refslice = 32 in AA)
% NB new default reference slice (aa_v3) is the last one (ie #1 for a descending
% sequence) - but does this mean TO should be 1, or 24?
xBF.UNITS      = 'scans';           % OPTIONS: 'scans'|'secs' for onsets
xBF.Volterra   = 1;                 % OPTIONS: 1|2 = order of convolution

for sub = 1:nsubs

    clear SPM
    disp(subs{sub})
    
    SPM.xY.RT = TR;                 % Scan repeat time, i.e. the TR
    SPM.xGX.iGXcalc = 'None';       % They type of global scaling to apply
    SPM.xVi.form = 'AR(1)';         % model to use for estimation of error auto-correlation
    SPM.xBF = xBF;                  % copies the basis function data above to the SPM variable
    
    csub = subs{sub};
    subdata = fullfile(dataroot, csub);
    % outplace = fullfile(res_dir, csub);
    
    %Set up analysis directory for model for each subject (within res_dir
    %directory)
    anadir = fullfile(res_dir, csub);
    
    if exist(anadir)~=7; 
        mkdir(res_dir, csub);
    end
    cd(anadir);

    tc = 0; %BC what does tc stand for? 
    blkc = 0; %BC what does blkc stand for?
    allfiles=''; 

    for sess = 1:nsess
        tc = tc+1; %BC Why not just use sess?

        %Look for scans here
        scansplace = ['Sess' num2str(sess)];
        sessdata = fullfile(subdata, scansplace);

        %grab the scans - imgfilt (above) tells it which version to use (eg
        %smoothed etc)
        files = spm_select('List', sessdata, imgfilt);
        
        %movement parameter stuff
        if incmoves==1
            mfname = spm_select ('List', sessdata, movefilt);
            moves = load(fullfile(sessdata,mfname));
        end
        
        SPM.nscan(tc) = size(files,1);

        %if it crashes here then your filter is probably set up wrong, or
        %you may be looking in the wrong place for the files
        clear ffiles
        for f =1:size(files,1)
            ffiles(f,:) = fullfile(sessdata,files(f,:));
        end
        allfiles = strvcat(allfiles,ffiles);

        %PUT BLOCK LOOP HERE
        descol = 0;
        blkon = 0;
        %for blk = 1:nblks
        
        timings_file = fullfile(stats_dir,[csub(7:9) '_' num2str(sess) '.txt']); % name of the file containing condition onset times etc
        timings = Exp4_extractevents(timings_file); % load the condition onsets

        %move_param_file = get_files(fullfile(sub_data,'Sess1'),'rp*.txt'); % file containing movement parameters
        %movement_parameters = load(move_param_file); % load the movement parameters

            % Get condition block type, event types, durations etc.
            c_st = timings(:,1); % switch type
            c_tt= timings(:,2); % task type
            c_rtt= c_tt;
            c_hand = timings(:,3); % hand used (for sanity check)
            c_acc = timings(:,4); % accuracy
            c_eons = timings(:,5) / 2000; % event onset time (in TRs)
            c_edur = timings(:,6) / 2000; % duration of event to response (in TRs)
            
                            
            %Event related design
            c_eons = c_eons(isfinite(c_edur));
            c_tt = c_tt(isfinite(c_edur));
            c_edur = c_edur(isfinite(c_edur));
                                      
            %SUBTRACT 9 DUMMY TRS 
            c_eons = c_eons - 8; % may need to change this to 8

            % now set into SPM design
            for cno = 1:ncond
                
                if cno < 7
                descol = descol+1;
                nm = {condnames{cno}}; %nm means name, it loads the name of condition 1,2,3...
                tmp = (c_tt == cno); % if c_typ = cno, tmp = 1. If not, tmp = 0
                
                if sum(tmp)==0
                    cno_eons = SPM.nscan(tc)-1;
                    cno_edur = 0.1;
                    SPM.realcol(tc,descol)=0;
                else
                    cno_eons = c_eons(tmp);
                    cno_edur = 0.1;
                    SPM.realcol(tc,descol)=1;
                end
                    
                SPM.Sess(tc).U(descol) = struct(...
                    'ons', cno_eons,...
                    'dur', cno_edur,...
                    'name',{nm},...
                    'P', struct('name','none')); % Parametric modulation
                
                else %i.e. for 7-12, the RT data
              
                descol = descol+1;
                nm = {condnames{cno}}; %nm means name, it loads the name of condition 1,2,3...
                tmp = (c_tt == cno); % if c_typ = cno, tmp = 1. If not, tmp = 0
                
                if sum(tmp)==0
                    cno_eons = SPM.nscan(tc)-1;
                    cno_edur = 0.1;
                    SPM.realcol(tc,descol)=0;
                else
                    cno_eons = c_eons(tmp);
                    cno_edur = C_edur(tmp);
                    SPM.realcol(tc,descol)=1;
                end
                    
                SPM.Sess(tc).U(descol) = struct(...
                    'ons', cno_eons,...
                    'dur', cno_edur,...
                    'name',{nm},...
                    'P', struct('name','none')); % Parametric modulation                    
                    

                end
                
            end
            
            % SPM.xX.K(blkc).HParam = hpf;
        %end

        SPM.xX.K(tc).HParam = hpf;
        
        if incmoves==1
            SPM.Sess(tc).C.C    = moves;     % [n x c double] covariates
            SPM.Sess(tc).C.name = mnames; % [1 x c cell]   names
        else
            SPM.Sess(tc).C.C = [];
            SPM.Sess(tc).C.name = {};
        end

    end

    cd (anadir)


    SPM.xY.P = allfiles;
    SPM = spm_fmri_spm_ui(SPM); %set up GLM
    spm_unlink(fullfile('.', 'mask.img')); % avoid overwrite dialog
    SPM = spm_spm(SPM);
    
    %now run other script to set the contrasts :)
    %VDT_addcontrasts(subs{sub});

end
