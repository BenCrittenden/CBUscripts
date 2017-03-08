clear all

%correlation of RT and Classification accuracy

% roishort = {'L_ACC','L_AI','L_APFC','L_Amyg','L_DLPFC','L_IFJ','L_IPS','L_Vis',...
%             'R_ACC','R_AI','R_APFC','R_Amyg','R_DLPFC','R_IFJ','R_IPS','R_Vis'};
        
% roishort = {'L_HF','L_LTC','L_PHC','L_PPC','L_Rsp','L_TPJ','L_TempP','L_aMPFC','L_pIPL',...
%     'R_HF','R_LTC','R_PHC','R_PCC','R_Rsp','R_TPJ','R_TempP','R_aMPFC','R_pIPL',...
%     'dMPFC','vMPFC'};

roishort = {'L_HF','L_LTC','L_PHC','L_PPC','L_Rsp','L_TPJ','L_TempP','L_aMPFC','L_pIPL',...
            'R_HF','R_LTC','R_PHC','R_PCC','R_Rsp','R_TPJ','R_TempP','R_aMPFC','R_pIPL',...
            'dMPFC','vMPFC','L_ACC','L_AI','L_APFC','L_Amyg','L_DLPFC','L_IFJ','L_IPS','L_Vis',...
            'R_ACC','R_AI','R_APFC','R_Amyg','R_DLPFC','R_IFJ','R_IPS','R_Vis'};
        
control_sn = [24 28 32 36];
MD_sn = [21:23 25:27 29:31 33:35];
Core_sn = [4 8 13 17];
MTL_sn = [1 3 5 9 10 12 14 18 20];
DMPFC_sn = [2 6 7 11 15 16 19];
        
taskpairs = {NaN,'12','13','14','15','16',...
             '21',NaN,'23','24','25','26',...
             '31','32',NaN,'34','35','36',...
             '41','42','43',NaN,'45','46',...
             '51','52','53','54',NaN,'56',...
             '61','62','63','64','65',NaN};
         
nrois = size(roishort);
nrois = nrois(2);
         
num_rows = 6;
num_cols = 6*nrois;


corr_supermatrix = NaN(num_rows,num_cols);
reg_supermatrix = corr_supermatrix;
goodness_supermatrix = corr_supermatrix;
mean_activation_diff = corr_supermatrix;
harder_task_matrix = corr_supermatrix;
         
%choose the ROI
for ROInum = 1:nrois
    
    currentROI = roishort{ROInum};
    display(currentROI())

    %choose the task pair
    for tasknum = 1:length(taskpairs)
        
        currentTasks = taskpairs{tasknum};        
        

        if ~isnan(currentTasks)
        %get the activation difference from all subs
        
        RT_vector = Get_RT(currentTasks);
        
        RT_vector = RT_vector';
        RT_hardertask = length(RT_vector(RT_vector>0));
        
        
              
        RTmean = mean(abs(RT_vector));
        RTsd = std(abs(RT_vector));                
        ZRT_vector = (abs(RT_vector) - RTmean) / RTsd;
        
              

        %get the CA from all subs
        
        CA_vector = MVPA_CApairs(currentROI,currentTasks)';
        
        if strcmp(currentROI(),'L_LTC')
            CA_vector = vertcat(NaN,CA_vector);
            RT_vector(1) = NaN;
        elseif strcmp(currentROI(),'R_TempP')
            CA_vector = vertcat(CA_vector(1:11),NaN,CA_vector(12:end)); % only case for L_LTC and R_TempP
            RT_vector(12) = NaN;
        end
        
        RT_all_SubsPairs(:,tasknum,ROInum) = RT_vector;        
        CA_all_SubsPairsROIs(:,tasknum,ROInum) = CA_vector;
       
        CAmean = mean(CA_vector);
        CAsd = std(CA_vector);
        
        ZCA_vector = (CA_vector - CAmean) / CAsd;
        
%         scatter(activation_vector,CA_vector);


        %correlate and regression of activation difference and CA
        corr_rho = corrcoef(RT_vector,CA_vector);
        corr_rho = corr_rho(1,2);
        r2 = corr_rho^2;
        
        reg_beta = polyfit(ZRT_vector,ZCA_vector,1);
        reg_beta = reg_beta(1); 


        else
            
            corr_rho = NaN;
            reg_beta = NaN;    
            r2 = NaN;
            RT_vector = NaN;
            RT_hardertask = NaN;
            
        end
        
        %save value to a matrix.
        
        mat_row = ceil(tasknum / 6);
        mat_col = ((ROInum -1)*6) + tasknum - ((mat_row-1)*6);
        
        corr_supermatrix(mat_row,mat_col) = corr_rho;
        reg_supermatrix(mat_row,mat_col) = reg_beta;
        goodness_supermatrix(mat_row,mat_col) = r2;
        mean_RT_diff(mat_row,mat_col) = mean(RT_vector);
        harder_task_matrix(mat_row,mat_col) = RT_hardertask;

    end

end



RT_all_SubsPairs = RT_all_SubsPairs(:,[2:6 9:12 16:18 23 24 30],:);
CA_all_SubsPairsROIs = (CA_all_SubsPairsROIs(:,[2:6 9:12 16:18 23 24 30],:)+50);

%%

dims = prod(size(CA_all_SubsPairsROIs));

RT_all = RT_all_SubsPairs;
RT_within = RT_all(:,[1 10 15],:);
RT_between = RT_all(:,[2:9 11:14],:);

CA_all = CA_all_SubsPairsROIs;
CA_within = CA_all(:,[1 10 15],:);
CA_between = CA_all(:,[2:9 11:14],:);

%% 

clear Core_betas
clear MTL_betas
clear DMPFC_betas

Core_CA_between = CA_between(:,:,Core_sn);
Core_RT_between = RT_between(:,:,Core_sn);
Core_CA_within = CA_within(:,:,Core_sn);
Core_RT_within = RT_within(:,:,Core_sn);

MTL_CA_between = CA_between(:,:,MTL_sn);
MTL_RT_between = RT_between(:,:,MTL_sn);
MTL_CA_within = CA_within(:,:,MTL_sn);
MTL_RT_within = RT_within(:,:,MTL_sn);

DMPFC_CA_between = CA_between(:,:,DMPFC_sn);
DMPFC_RT_between = RT_between(:,:,DMPFC_sn);
DMPFC_CA_within = CA_within(:,:,DMPFC_sn);
DMPFC_RT_within = RT_within(:,:,DMPFC_sn);


for sub = 1:size(Core_CA_between,1)
    
    CA_b_dat = vertcat(squeeze(Core_CA_between(sub,:,:)),zeros(3,size(Core_CA_between,3)));
    RT_b_dat = squeeze(Core_RT_between(sub,:,:));
    
    CA_w_dat = vertcat(zeros(12,size(Core_CA_within,3)),squeeze(Core_CA_within(sub,:,:)));
    RT_w_dat = squeeze(Core_RT_within(sub,:,:));
    
    RT_dat = abs(vertcat(RT_b_dat,RT_w_dat));
    RT_dat = RT_dat(:,1);
    
    
    for roi = 1:size(CA_w_dat,2)
        
%         input_matrix = [CA_b_dat(:,roi) CA_w_dat(:,roi)];
%         [m b w] = glmfit(input_matrix,RT_dat,'normal');
%         Core_betas(sub,roi,:) = m';

        [m1 b w] = glmfit(RT_dat(1:12),CA_b_dat((1:12),roi),'normal');
        [m2 b w] = glmfit(RT_dat(13:15),CA_w_dat(13:15,roi),'normal');
        
        Core_betas(sub,roi,:) = [m1(2) m2(2)];    
     
    end
    
    clear('CA_b_dat','CA_w_dat');
    
    CA_b_dat = vertcat(squeeze(MTL_CA_between(sub,:,:)),zeros(3,size(MTL_CA_between,3)));
    CA_w_dat = vertcat(zeros(12,size(MTL_CA_within,3)),squeeze(MTL_CA_within(sub,:,:)));
        
    for roi = 1:size(CA_w_dat,2)
        
%         input_matrix = [CA_b_dat(:,roi) CA_w_dat(:,roi)];
%         [m b w] = glmfit(input_matrix,RT_dat,'normal');
%         MTL_betas(sub,roi,:) = m;
        
        [m1 b w] = glmfit(RT_dat(1:12),CA_b_dat((1:12),roi),'normal');
        [m2 b w] = glmfit(RT_dat(13:15),CA_w_dat(13:15,roi),'normal');
        
        MTL_betas(sub,roi,:) = [m1(2) m2(2)]; 
     
    end
    
    clear('CA_b_dat','CA_w_dat');
    
    CA_b_dat = vertcat(squeeze(DMPFC_CA_between(sub,:,:)),zeros(3,size(DMPFC_CA_between,3)));
    CA_w_dat = vertcat(zeros(12,size(DMPFC_CA_within,3)),squeeze(DMPFC_CA_within(sub,:,:)));
    
    CA_b_dat(isnan(CA_b_dat)) = 1;
    CA_w_dat(isnan(CA_w_dat)) = 1;
        
    for roi = 1:size(CA_w_dat,2)
        
%         input_matrix = [CA_b_dat(:,roi) CA_w_dat(:,roi)];
%         [m b w] = glmfit(input_matrix,RT_dat,'normal');
%         
%         %for the missing ROIs in two subs:
%         if sub == 1 && roi == 1
%             m = [NaN NaN NaN]'; 
%         elseif sub == 12 && roi == 6
%             m = [NaN NaN NaN]';
%         end
%         
%         DMPFC_betas(sub,roi,:) = m;
        
        [m1 b w] = glmfit(RT_dat(1:12),CA_b_dat((1:12),roi),'normal');
        [m2 b w] = glmfit(RT_dat(13:15),CA_w_dat(13:15,roi),'normal');
        
        %for the missing ROIs in two subs:
        if sub == 1 && roi == 1
            m = [NaN NaN]'; 
        elseif sub == 12 && roi == 6
            m = [NaN NaN]';
        end
        
        DMPFC_betas(sub,roi,:) = [m1(2) m2(2)]; 
                
        
     
    end
    
end

%average across task-pair types within each sub-network.
Core_mean_betas = squeeze(nanmean(Core_betas,2));
MTL_mean_betas = squeeze(nanmean(MTL_betas,2));
DMPFC_mean_betas = squeeze(nanmean(DMPFC_betas,2));

clear Core_betas
clear MTL_betas
clear DMPFC_betas
%%

[C ind] = sort(Core_mean_betas(:,2:3));
% [A ind] = sort(DMPFC_mean_betas(:,2));
% B = sort(DMPFC_mean_betas(:,3))
A = sort(DMPFC_mean_betas(:,2));
B = sort(DMPFC_mean_betas(:,3));
% A = A(ind);
% B = B(ind);



% core: [1 0.65 0],[1 0.95 0]
% MTL: [0 0.95 0],[0 0.65 0.]
% DMPFC: [0 0.05 0.65],[0.2 0.3 1]


figure,
hold on


h3 = bar(A,'r','EdgeColor','k');
% h2 = bar(B,'b','EdgeColor','k');

axes = [-inf inf -15 10];
axis(axes)
% set(gca,'XTick',0:300:1200)

whitebg('w')

Xlabel = xlabel('');
Ylabel = ylabel('beta estimate');

set([gca Xlabel Ylabel],...
    'FontName',     'Helvetica',...
    'FontSize',     24,...
    'FontWeight',   'bold');

set(gca,...
    'Box',          'off',...
    'TickDir',      'out',...
    'TickLength',   [0.005 0.005],...
    'XMinorTick',   'off',...
    'YMinorTick',   'off',...
    'YGrid',        'off',...
    'XGrid',        'off',...
    'XColor',       [0 0 0],...
    'YColor',       [0 0 0],...
    'LineWidth',    2);

set(gca,'XTick',[])

hold off



