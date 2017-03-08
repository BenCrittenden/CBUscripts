% Conn batch script - just 'resting' state

clear all

addpath(genpath('/imaging/bc01/toolboxes/conn'))

hDir = '/imaging/bc01/Experiments4_5/Nov_2012/Connectivity';
iDir = '/imaging/bc01/Experiments4_5/Nov_2012/Preprocessed_Data';
BATCH.filename = fullfile(hDir,'Rest4.mat');

RestingState = 1;


SubNames = {'CBU120564','CBU120565','CBU120566','CBU120567','CBU120595',...
      'CBU120597','CBU120602','CBU120609','CBU120612','CBU120615',...
      'CBU120618','CBU120620','CBU120625','CBU120626','CBU120628',...
      'CBU121074','CBU121075','CBU121076'};
  
roiNames = {'R_Par','R_IFJ','R_DLPFC','R_APFC','R_AI','R_ACC',...
            'L_Par','L_IFJ','L_DLPFC','L_APFC','L_AI','L_ACC',...
            'R_Amyg','L_Amyg'}; %'R_Vis','L_Vis'
  
nSess = 4;




%%

Batch.Setup.RT = 2;
BATCH.Setup.nsubjects = 18;
BATCH.Setup.acquisitiontype = 1; %continuous acquisition
BATCH.Setup.analyses = 1; %ROI to ROI only
BATCH.Setup.analysisunits = 1; %percent signal change
BATCH.Setup.outputfiles = [0 1 0 0 0 0]; %outputs nifty volumes for confound corrected BOLD

%Get Functional Data
for cSub = 1:length(SubNames)
    
    for cSess = 1:nSess
        
        useDir = fullfile(iDir,SubNames{cSub},['Sess' num2str(cSess)]);
        
        imgfilt = '^swarf.*\.nii$';
        f_files = spm_select('List', useDir, imgfilt);
        
        uD4cat = repmat([useDir '/'],[size(f_files,1),1]);
        f_files = [uD4cat f_files];
        
        BATCH.Setup.functionals{cSub}{cSess} = f_files;
    
        useDir = fullfile(iDir,SubNames{cSub},'Structural');
        
        imgfilt = '^wms.*\.nii$'; %'^wc2ms.*\.nii$';
        s_files = spm_select('List', useDir, imgfilt);
        
        uD4cat = repmat([useDir '/'],[size(s_files,1),1]);
        s_files = [uD4cat s_files];        
        
        BATCH.Setup.structurals{cSub}{cSess} = s_files;
        
    end
    
end

% BATCH.New.step{} preprocessing steps - I've already done this though

BATCH.Setup.roiextract = 1; %soucre of functional data for ROI timesereies is the same as that in the 'functionals' field
% BATCH.Setup.roiextract_rule =  don't know what this does really
% BATCH.Setup.masks.Grey

BATCH.Setup.rois.names = roiNames;

for cr = 1:length(roiNames)
    
    roiDir = '/imaging/bc01/ROIs/Canonical_MD/img';
    
    BATCH.Setup.rois.files{cr} = fullfile(roiDir,['MD_' roiNames{cr} '_roi.img']);
    
end

BATCH.Setup.rois.dimensions = {ones(1,length(roiNames))}; %only extracts the mean
BATCH.Setup.rois.mask = 1; %mask with greymatter mask, default is 0.
BATCH.Setup.rois.regresscovariates = 0; %only relevant if dimensions is >1.
BATCH.Setup.rois.roiextract = 1; %uses Setup.roi parameters rather than functional ones.

BATCH.Setup.conditions.names = {'onTask','offTask'};

if RestingState
    
    BATCH.Setup.conditions.names = {'rest'};
    
    for cSub = 1:length(SubNames)
    
        for cSess = 1:nSess
            
            BATCH.Setup.conditions.onsets{1}{cSub}{cSess} = 0;
            BATCH.Setup.conditions.durations{1}{cSub}{cSess} = Inf;
            
        end
    end
    
    
elseif ~RestingState
    
    BATCH.Setup.conditions.names = {'onTask','offTask'};
    
    BATCH.Setup.conditions.onsets = {};
    
    
    timings_file = fullfile(stats_dir,[csub(7:9) '_' num2str(sess) '.txt']); % name of the file containing condition onset times etc
    timings = Exp4_extractevents(timings_file); % load the condition onsets
    
    
    % Get condition block type, event types, durations etc.
    c_st = timings(:,1); % switch type
    c_tt= timings(:,2); % task type
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
       
end

BATCH.Preprocessing.done = 1;

BATCH.Setup.done = 1; %whether to run initial data extraction steps, not sure if this should be 1 or 0.
BATCH.Setup.overwrite = 'No';
BATCH.Setup.isnew = 1;

conn_batch(BATCH);

%% Analysis

% 
% BATCH.Analysis.sources = roiNames;
% BATCH.Analysis.analysis_number = 1;
% BATCH.Analysis.type = 1;
% BATCH.Analysis.measure = 1; %pearson correlation, the default.
% 
% 
% %Theres a few other fields that may need to be defined here.
% 
% BATCH.Analysis.done = 1;
% BATCH.Analysis.overwirte = 'No';





































