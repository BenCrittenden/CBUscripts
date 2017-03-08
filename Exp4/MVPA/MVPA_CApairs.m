function CA_vector = MVPA_CApairs(ROI,pair)

% average decoding of tasks compared in each ROI

%find files


DMN_ROIs = {'L_HF','L_LTC','L_PHC','L_PPC','L_Rsp','L_TPJ','L_TempP','L_aMPFC','L_pIPL',...
    'R_HF','R_LTC','R_PHC','R_PCC','R_Rsp','R_TPJ','R_TempP','R_aMPFC','R_pIPL',...
    'dMPFC','vMPFC'};

MDN_ROIs = {'L_ACC','L_AI','L_APFC','L_Amyg','L_DLPFC','L_IFJ','L_IPS','L_Vis',...
    'R_ACC','R_AI','R_APFC','R_Amyg','R_DLPFC','R_IFJ','R_IPS','R_Vis'};


if sum(strcmp(ROI,DMN_ROIs))
    
    network = 'DMN';
    root_dir = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/MVPA/ROI/DM_Zx-Results';
    
    if strcmp(ROI,'L_PPC')
        ROI = 'L_PCC';
    end    
    Sub_list = dir(fullfile(root_dir,['r' ROI '_roi']));
    
%     if strcmp(ROI,'L_LTC')
%         Sub_list = dir('/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/MVPA/ROI/rL_LTC_roi');
%     elseif strcmp(ROI,'R_TempP')
%         Sub_list = dir('/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/MVPA/ROI/rR_Temp_roi');
%     end
    
elseif sum(strcmp(ROI,MDN_ROIs))
    
    network = 'MDN';
    root_dir = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/MVPA/ROI/Zx-Results';
    
    if strcmp(ROI,'L_IPS')
        ROI = 'L_Par';
    elseif strcmp(ROI,'R_IPS')
        ROI = 'R_Par';
    end
    Sub_list = dir(fullfile(root_dir,['rMD_' ROI '_roi']));
    
end


mat_file = 'res_accuracy_minus_chance.mat';
num_tasks = 6;
num_subs = 18;
ROI_array = [];

% num_cols = length(ROI_list) * num_tasks;
% num_rows = num_tasks;
% ROI_data = NaN(num_rows,num_cols);


    if strcmp(ROI,'L_LTC')
        Sub_list = Sub_list(3:19);
    elseif strcmp(ROI,'R_TempP')
        Sub_list = Sub_list(3:19);
    else    
        Sub_list = Sub_list(3:20);
    end
                                 
                for current_Sub = 1:length(Sub_list)
                
                    if strcmp(network,'MDN')
                        working_dir = fullfile(root_dir,['rMD_' ROI '_roi'],Sub_list(current_Sub).name);
                    elseif strcmp(network,'DMN')
                        working_dir = fullfile(root_dir,['r' ROI '_roi'],Sub_list(current_Sub).name);
                    end
                
                con_folder = dir(fullfile(working_dir,pair));
                
                if isempty(con_folder)
                    
                    pair = [pair(2) pair(1)];
                    con_folder = dir(fullfile(working_dir,pair));
                                   
                end
                
                                   
                temp = load(fullfile(working_dir,pair,mat_file));
                
                ROI_array = [ROI_array temp.resultsmat];
                
                
                                              
                end               
                
               CA_vector = ROI_array;
            
end
