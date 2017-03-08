clear


fn = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/ROI/MD_Switchs_ROIres/roi_percent1.txt';
fsave = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/ROI/MD_Switchs_ROIres/roi_percent1_sorted_mean2.txt';



%open file
fid = fopen(fn,'r');
%Read the first line of the file containing the header information

x=0;
while x ~= 1;
    headerline = fgetl(fid);
    x = findstr('sub',headerline);
    if isempty(x) == 1
        x = 0;
    end

end

%The file pointer is now at the beginning of the second line. Use TEXTSCAN 
%to read the columns of data.
%s = string, f = decimal number, d = integer

num_rois = 16;
num_sess = 4;
num_regressors = 3;
num_subs = 18;

num_clmns = num_rois*num_sess*num_regressors;
data = textscan(fid,['%s' repmat('%f',1,num_clmns)]);

num_rows = num_subs*num_sess;

%close file
fclose(fid);

% headers = textscan(headerline,'%s','Delimiter','\t');
headers = textscan(headerline,'%s','Delimiter'); %,'\t' 

for k = 1:length(headers{:});
    eval([headers{1}{k} '= data{k};'])
end

All_results = [];
All_results_ticker = 0;
All_titles = {};


roishort = {'L_ACC','L_AI','L_APFC','L_Amyg','L_DLPFC','L_IFJ','L_IPS','L_Vis',...
            'R_ACC','R_AI','R_APFC','R_Amyg','R_DLPFC','R_IFJ','R_IPS','R_Vis'};
        
% roishort = {'L_HF','L_LTC','L_PHC','L_PPC','L_Rsp','L_TPJ','L_TempP','L_aMPFC','L_pIPL',...
%     'R_HF','R_LTC','R_PHC','R_PCC','R_Rsp','R_TPJ','R_TempP','R_aMPFC','R_pIPL',...
%     'dMPFC','vMPFC'};        
        
evshort = {'None','Within','Between'};

for curr_roi = 1:num_rois
    
   roi_name = roishort{curr_roi};
    
    
    curr_regressor = 1;
        
    regressor_name = evshort{curr_regressor};
        
    temp1 = [];
        
    for curr_sess = 1:num_sess
        
    temp1 = [temp1 (eval([roi_name num2str(curr_sess) '_' regressor_name]))];
                    
    end
    
    %==
    
    curr_regressor = 2;
        
    regressor_name = evshort{curr_regressor};
        
    temp2 = [];
        
    for curr_sess = 1:num_sess
        
    temp2 = [temp2 (eval([roi_name num2str(curr_sess) '_' regressor_name]))];
                    
    end
    
    %==
    
    curr_regressor = 3;
        
    regressor_name = evshort{curr_regressor};
        
    temp3 = [];
        
    for curr_sess = 1:num_sess
        
    temp3 = [temp3 (eval([roi_name num2str(curr_sess) '_' regressor_name]))];
                    
    end
    
    %==
        
    within_none = mean((temp2 - temp1),2);
    between_none = mean((temp3 - temp1),2)
    
    av = mean(between_none)
    
    plot(between_none)
    
    
%     temp_mean = mean(temp');
%     temp_mean = temp_mean';
        
    create_variable = [roi_name '_within-none'];
           
    %create variable from string
    All_results_ticker = All_results_ticker+1;
    All_results(:,All_results_ticker) = within_none;
        
    All_titles{1,All_results_ticker} = create_variable;
        
%         eval([create_variable '= temp;']);

    create_variable = [roi_name '_between-none'];
           
    %create variable from string
    All_results_ticker = All_results_ticker+1;
    All_results(:,All_results_ticker) = between_none;
        
    All_titles{1,All_results_ticker} = create_variable;
       
       
      
       
    
end

%write to a new text file

fids = fopen(fsave,'a');

fprintf(fids,'%s\t',All_titles{:});
fprintf(fids,'\n');

for curr_row = 1:num_subs
    fprintf(fids,'%f\t',All_results(curr_row,:));
    fprintf(fids,'\n');
end

fclose(fids);


