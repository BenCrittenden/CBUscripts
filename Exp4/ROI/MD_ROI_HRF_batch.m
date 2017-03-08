clear

%Expt21vf - ROI analysis batch script. Based on one picked up from
%//imaging/russell/

%make sure marsbar is on matlab path
mbd = fullfile(spm('dir'),'toolbox','marsbar');
if exist(mbd)==7; addpath(mbd); end

% Set paths etc ***********************************************************
rootdir = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/Smoothed/SM_Tasks'; %main analysis directory
roidir = '/imaging/bc01/ROIs/Canonical_MD';% directory containing roi.mat files
resdir = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/ROI/MD_Task_HRF_ROI';
if exist(resdir)~=7;mkdir(resdir);end

roi_summary_function = 'mean'; % what function marsbar uses to summarise
%roi data over voxels. options= 'mean', 'median', 'eig1', 'wtmean'

subfilt = 'CBU12*';
modeldur=1;

% results structure
res = struct('roi','','subs','','beta',[],...
    'percent',[],'dims','roi, sub, event');

% names of output files. The script will save the res structure to a matlab
% mat file, and also write the results to tab delimited text files (these
% are useful for reading into Excel etc.
resmat = fullfile(resdir,'roi_results1.mat');
restxtb = fullfile(resdir,'roi_betas1.txt');
restxtp = fullfile(resdir,'roi_percent1.txt');



% Get subs ****************************************************************
%(find all individual subject directories within the root directory)
subs = dir(fullfile(rootdir,subfilt));
subs = cellstr(deblank(char(subs.name)));
exsubs = {};

for s = 1:size(exsubs,2)
    exi = strfind(subs,exsubs{s});
    exi = char(exi{:})==' ';
    subs = subs(exi==1);
end

nsubs = length(subs);


% Get ROIs ****************************************************************
%find all roi.mat files in the roi directory
rois = spm_select('List',roidir,'roi.mat$');
nrois = size(rois,1);
res.rois = rois;
rois = [repmat([roidir filesep],nrois,1) rois];



% Loop through subs *******************************************************
try
    load(resmat)
catch
    for s=1:nsubs
        clear SPM f
        csub = subs{s};

        sn = sprintf('%s\n%s\t%s','','sub','roi');

        % get SPM.mat file for the current subject...
        datadir = fullfile(rootdir,csub);   % BC: deleted ',univariate2', after csub
        desfile = fullfile(datadir,'SPM.mat');
        SPM = load(desfile);
        D = mardo(SPM);


        % Loop through ROIs ***************************************************
        for r=1:nrois
            croi = deblank(rois(r,:));

            disp(sprintf('%s\n%s   :   %s\n%s',repmat('*',20,1),csub,croi,repmat('*',20,1)))


            % ==============================================================
            % this is the main marsbar analysis...
            % ==============================================================

            R = maroi(croi); % load roi into a marsbar maroi object structure
            Y = get_marsy(R,D,roi_summary_function); % get summarised time course for this ROI
            E = estimate(D,Y); % estimate design based on this summarised time course
            SPM = des_struct(E); %unpack marsbar design structure
            smeans = SPM.betas(SPM.xX.iB); % session means - these are used for calculating percent signal change
            res.beta{r,s} = SPM.betas(SPM.xX.iC); % load beta values for effects of interest into results structure

            % ==============================================================


            % calculate percent signal change for each beta value, marsbar
            % style. 
            
            %AB: Note that the interpretation of % signal change depends
            %heavily on what you consider your baseline to be. So, think
            %about that. 
            i=0;
            res.percent{r,s}=[];
            for sess = 1:size(SPM.Sess,2)
                for ev = 1:size(SPM.Sess(sess).col,2)
                    cc = SPM.Sess(sess).col(ev);
                    cb = SPM.betas(cc);

                    if ev<=length(SPM.Sess(sess).U)
                        if modeldur
                            evdur = mean(SPM.Sess(sess).U(ev).dur);
                        else
                            evdur=1;
                        end

                        if evdur==0
                            sf = zeros(SPM.xBF.T,1);
                            sf(1) = SPM.xBF.T;
                        else
                            sf = ones(round(evdur/SPM.xBF.dt), 1);
                        end

                        X = [];
                        for b = 1:size(SPM.xBF.bf,2)
                            X = [X conv(sf, SPM.xBF.bf(:,b))];
                        end

                        Yh = X*cb;
                        [d i] = max(abs(Yh), [], 1);
                        d = Yh(i);
                    else
                        d=cb;
                    end

%                     res.percent{r,s}(end+1,:)= 100*(d/smeans(sess));
                end
            end
        end
    end
    save(resmat,'res');

end



% =========================================================================
% Format results for output as tab delimited text files.
% NB - be careful that all subs have the same events in the same columns!!
% =========================================================================

nsess = 4;

%These are short labels for the regressors - useful in excel
evshort = {'T1','T2','T3','T4','T5','T6'};

%These are short labels for the rois - useful in excel
%BC - correct order can be seen by what is loaded as the variable 'rois' around
%line 66.
roishort = {'L_ACC','L_AI','L_APFC','L_Amyg','L_DLPFC','L_IFJ','L_IPS','L_Vis',...
            'R_ACC','R_AI','R_APFC','R_Amyg','R_DLPFC','R_IFJ','R_IPS','R_Vis'};

fidb = fopen(restxtb,'a');
fidp = fopen(restxtp,'a');

str = 'sub';
for r = 1:nrois
    for sess = 1:nsess
        for ev = 1:length(evshort)
            str = sprintf('%s\t%s%0.0f_%s',str,roishort{r},sess,evshort{ev});
        end
    end
end

fprintf(fidb,'%s',str);
fprintf(fidp,'%s',str);


sb = '';
sp= '';

for s = 1:nsubs
    sb =subs{s};
    sp = sb;
    y=0;
    for r=1:nrois
        x=0;
        for sess = 1:nsess
            for ev = 1:length(evshort)
                x=x+1;
                y=y+1;
                sb = sprintf('%s\t%0.5f',sb,res.beta{r,s}(x));
                sp = sprintf('%s\t%0.5f',sp,res.percent{r,s}(x));
            end
        end
    end

    fprintf(fidb,'%s\n%s','',sb);
    fprintf(fidp,'%s\n%s','',sp);
end

fclose(fidp);
fclose(fidb);
disp('done')