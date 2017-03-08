clear all

addpath('/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/MVPA');

% This script takes the p value for each task pair across all ROIs and then
% uses that to calculate what the FDR corrected alpha should be for
% significance.

load('/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/MVPA/ROI/MDZx-pvals-3Mar13.mat')
A = ROI_data_pvalue;
load('/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/MVPA/ROI/DMZx-pvals-3Mar13.mat')
B = ROI_data_pvalue;
ROI_data_all = A; %horzcat(A,B);

% if only doing active MD regions, i.e. not vis cortex and amyg, remove
% these rois


ROI_data_all(:,[19:24 43:48 67:72 91:96]) = [];



dims = size(ROI_data_all);

dim1 = dims(1).*dims(1);
dim2 = (dims(2)./dims(1));

temp = reshape(ROI_data_all,dim1,dim2);
remove_all = [NaN 1 1 1 1 1 NaN NaN 1 1 1 1 NaN NaN NaN 1 1 1 NaN NaN NaN NaN...
            1 1 NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN]';
        
remove_between = [NaN NaN 1 1 1 1 NaN NaN 1 1 1 1 NaN NaN NaN NaN 1 1 NaN NaN NaN NaN...
            1 1 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN]';
        
remove_within = [NaN 1 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN...
            NaN NaN NaN NaN NaN NaN NaN 1 NaN NaN NaN NaN NaN NaN]';

remove_all = repmat(remove_all,[1,dim2]);

temp_all = remove_all.*temp;
temp_all(isnan(temp_all)) = [];
all = reshape(temp_all,[15 dim2]);

nrois = size(all,2)

all_for_fdr = reshape(all,[15*nrois,1]);
adjusted_p = fdr(all_for_fdr);  


display('done')