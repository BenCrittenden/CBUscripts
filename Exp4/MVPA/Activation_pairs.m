function activation_vector = Activation_pairs(ROI,pair)

DMN_ROIs = {'L_HF','L_LTC','L_PHC','L_PPC','L_Rsp','L_TPJ','L_TempP','L_aMPFC','L_pIPL',...
    'R_HF','R_LTC','R_PHC','R_PCC','R_Rsp','R_TPJ','R_TempP','R_aMPFC','R_pIPL',...
    'dMPFC','vMPFC'};

MDN_ROIs = {'L_ACC','L_AI','L_APFC','L_Amyg','L_DLPFC','L_IFJ','L_IPS','L_Vis',...
    'R_ACC','R_AI','R_APFC','R_Amyg','R_DLPFC','R_IFJ','R_IPS','R_Vis'};


if sum(strcmp(ROI,DMN_ROIs)) 
    fn = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/ROI/DM_Tasks_ROIres/roi_betas1_sorted_means.txt';
    firstROI = 'L_HF_Shoebox';
elseif sum(strcmp(ROI,MDN_ROIs))
    fn = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/ROI/MD_Tasks_ROIres/roi_betas1_sorted_means.txt';
    firstROI = 'L_ACC_Shoebox';
end


%open file
fid = fopen(fn,'r');
%Read the first line of the file containing the header information

x=0;
while x ~= 1;
    headerline = fgetl(fid);
    x = findstr(firstROI,headerline);
    if isempty(x) == 1
        x = 0;
    end

end

num_subs = 18;
num_rois = 20;
num_regressors = 6;

num_clmns = num_rois*num_regressors;

data = textscan(fid,[repmat('%f',1,num_clmns)]);

%close file
fclose(fid);

% headers = textscan(headerline,'%s','Delimiter','\t');
headers = textscan(headerline,'%s','Delimiter'); %,'\t' 

for k = 1:length(headers{:})
eval([headers{1}{k} '= data{k};']);  
end

% roishort = {'L_ACC','L_AI','L_APFC','L_DLPFC','L_IFJ','L_IPS',...
%             'R_ACC','R_AI','R_APFC','R_DLPFC','R_IFJ','R_IPS'};
        
evshort = {'Shoebox','Living','shape','height','A','I'};

   roi_name = ROI;
 
    
    curr_vert_regressor = str2num(pair(1));
        
               
        regressor_name = evshort{curr_vert_regressor};
        
        temp = [];
        
        roi_vert = (eval([roi_name '_' regressor_name]));
               
        
        curr_hor_regressor = str2num(pair(2));
        
        regressor_name = evshort{curr_hor_regressor};
        
        temp = [];
        
        roi_hor = (eval([roi_name '_' regressor_name]));
               
        activation_vector = (roi_vert - roi_hor);
        
      

end







