%% First, set the defaults and define the analysis you want to perform

addpath('/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/MVPA/WholeBrain')
addpath(genpath('/imaging/bc01/toolboxes/the_decoding_toolbox'))

% Specify the data root directory
data_root_dir = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/NonSmoothed/noSM_Tasks';
roi_dir = '/imaging/bc01/ROIs/Canonical_MD/img';

% Specify where the results should be saved
results_root_dir = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/MVPA/ROI/Z-Results'; 

% Enter which analysis method you like
% The standard decoding method is searchlight, but we should still enter 
% it to be on the safe side.
% cfg.analysis = 'searchlight';

subs={'CBU120564','CBU120565','CBU120566','CBU120567','CBU120595',...
      'CBU120597','CBU120602','CBU120609','CBU120612','CBU120615',...
      'CBU120618','CBU120620','CBU120625','CBU120626','CBU120628',...
      'CBU121074','CBU121075','CBU121076'};


for sub = 1:length(subs)

beta_dir = fullfile(data_root_dir,subs{sub});

%% Second, get the file names, labels and run number of each brain image
%% file to use for decoding.

% Choose the mask/ROI

% cfg.files.mask = ;
cfg.analysis = 'roi';

sub_mask = [beta_dir '/mask.img'];
% roi_writefolder = [roi_dir '/' subs{sub}];fullfile(data_root_dir,subs{sub},'beta_0001.img')

% roi_files = spm_select('FPlist',roi_dir,'.*.img');
roi_files = dir(fullfile(roi_dir,'*img'));

for roi_num = 1:length(roi_files)
    roi_file = fullfile(roi_dir, roi_files(roi_num).name);
    spm_reslice(char(sub_mask,roi_file),struct('which',1,'mean',0));
        
    %move files
    imgfile_origin = fullfile(roi_dir, ['r' roi_files(roi_num).name]);
    
    len = length(roi_files(roi_num).name);
    hdrfile_origin = fullfile(roi_dir, ['r' roi_files(roi_num).name(1:len-3) 'hdr']);
        
        file_dest = fullfile(roi_dir,'Exp4_MVPA',subs{sub});
        if exist(file_dest,'dir')~=7;mkdir(file_dest);end
        
        movefile(imgfile_origin,file_dest);
        movefile(hdrfile_origin,file_dest);
        
        display(['roi = ' num2str(roi_num)])
        
end

ROI_list = spm_select('FPlist',file_dest,'rMD.*.img');


[lenROI_list junk] = size(ROI_list);

for current_roi = 1:lenROI_list
    
cfg.files.mask = ROI_list(current_roi,:);
[path ROI_name ext] = fileparts(ROI_list(current_roi,:));

% find the regressor names
regressor_names = design_from_spm(beta_dir);

% construct the decoding design

labelname = {' '};
labelname = repmat(labelname,1,2);

row = 0;
column = 0;
curr_con = 0;

for row = 1:6;
    
for column = (row + 1):6;
        
       labelname{1,1} = {['Condition' num2str(row)]};
       labelname{1,2} = {['Condition' num2str(column)]};
       
       curr_con = [num2str(row) num2str(column)];
       
       Labels = [1 -1];

Labelnames = {labelname{1} labelname{2}};    
cfg = decoding_prepare_design(cfg,Labelnames,Labels,regressor_names,beta_dir);

cfg.results.dir = fullfile(results_root_dir,ROI_name,subs{sub},curr_con);

cfg.scale.method = 'z'; %apply z-scoring to the data.
cfg.scale.estimation = 'across';



% === Automatic Creation ===
% This creates the leave-one-run-out cross validation design:
cfg.design = make_design_cv(cfg);
print_design(cfg);


%% Fourth, set additional parameters manually

% Searchlight-specific parameters
% cfg.searchlight.unit = 'mm';
% cfg.searchlight.radius = 6; % this will yield a searchlight radius of 6mm.
% cfg.searchlight.spherical = 1;

% Other parameters of interest:
% The verbose level allows you to determine how much output you want to see
% on the console while the program is running (0: no output, 1: normal 
% output, 2: high output).
cfg.verbose = 1;

% parameters for libsvm (linear SV classification, cost = 1, no screen output)
cfg.decoding.train.classification.model_parameters = '-s 0 -t 0 -c 1 -b 0 -q'; 

%% Fifth, run the decoding analysis

% Fingers crossed it will not generate any error messages ;)
results = decoding(cfg);

end
end
            
end 

end
