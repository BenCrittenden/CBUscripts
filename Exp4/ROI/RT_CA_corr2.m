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


xROIs_RT_between = squeeze(RT_between(:,:,1));
xROIs_RT_between = abs(reshape(xROIs_RT_between,numel(xROIs_RT_between),1));
xROIs_CA_between = squeeze(nanmean(CA_between,3));
xROIs_CA_between = reshape(xROIs_CA_between,numel(xROIs_CA_between),1);

xROIs_RT_within = squeeze(RT_within(:,:,1));
xROIs_RT_within = abs(reshape(xROIs_RT_within,numel(xROIs_RT_within),1));
xROIs_CA_within = squeeze(nanmean(CA_within,3));
xROIs_CA_within = reshape(xROIs_CA_within,numel(xROIs_CA_within),1);

xROIs_MD_CA_between = squeeze(nanmean(CA_between(:,:,MD_sn),3));
xROIs_MD_CA_between = reshape(xROIs_MD_CA_between,numel(xROIs_MD_CA_between),1);
xROIs_Core_CA_between = squeeze(nanmean(CA_between(:,:,Core_sn),3));
xROIs_Core_CA_between = reshape(xROIs_Core_CA_between,numel(xROIs_Core_CA_between),1);
xROIs_MTL_CA_between = squeeze(nanmean(CA_between(:,:,MTL_sn),3));
xROIs_MTL_CA_between = reshape(xROIs_MTL_CA_between,numel(xROIs_MTL_CA_between),1);
xROIs_DMPFC_CA_between = squeeze(nanmean(CA_between(:,:,DMPFC_sn),3));
xROIs_DMPFC_CA_between = reshape(xROIs_DMPFC_CA_between,numel(xROIs_DMPFC_CA_between),1);
xROIs_control_CA_between = squeeze(nanmean(CA_between(:,:,control_sn),3));
xROIs_control_CA_between = reshape(xROIs_control_CA_between,numel(xROIs_control_CA_between),1);

xROIs_MD_CA_within = squeeze(nanmean(CA_within(:,:,MD_sn),3));
xROIs_MD_CA_within = reshape(xROIs_MD_CA_within,numel(xROIs_MD_CA_within),1);
xROIs_Core_CA_within = squeeze(nanmean(CA_within(:,:,Core_sn),3));
xROIs_Core_CA_within = reshape(xROIs_Core_CA_within,numel(xROIs_Core_CA_within),1);
xROIs_MTL_CA_within = squeeze(nanmean(CA_within(:,:,MTL_sn),3));
xROIs_MTL_CA_within = reshape(xROIs_MTL_CA_within,numel(xROIs_MTL_CA_within),1);
xROIs_DMPFC_CA_within = squeeze(nanmean(CA_within(:,:,DMPFC_sn),3));
xROIs_DMPFC_CA_within = reshape(xROIs_DMPFC_CA_within,numel(xROIs_DMPFC_CA_within),1);
xROIs_control_CA_within = squeeze(nanmean(CA_within(:,:,control_sn),3));
xROIs_control_CA_within = reshape(xROIs_control_CA_within,numel(xROIs_control_CA_within),1);

[RHO_xROIs_within,PVAL_xROIs_within] = corr(xROIs_CA_within,xROIs_RT_within,'Type','Spearman');
[RHO_xROIs_between,PVAL_xROIs_between] = corr(xROIs_CA_between,xROIs_RT_between,'Type','Spearman');

[RHO_xROIs_MD_within,PVAL_xROIs_within] = corr(xROIs_MD_CA_within,xROIs_RT_within,'Type','Spearman');
[RHO_xROIs_MD_between,PVAL_xROIs_between] = corr(xROIs_MD_CA_between,xROIs_RT_between,'Type','Spearman');

[RHO_xROIs_Core_within,PVAL_xROIs_within] = corr(xROIs_Core_CA_within,xROIs_RT_within,'Type','Spearman');
[RHO_xROIs_Core_between,PVAL_xROIs_between] = corr(xROIs_Core_CA_between,xROIs_RT_between,'Type','Spearman');

[RHO_xROIs_MTL_within,PVAL_xROIs_within] = corr(xROIs_MTL_CA_within,xROIs_RT_within,'Type','Spearman');
[RHO_xROIs_MTL_between,PVAL_xROIs_between] = corr(xROIs_MTL_CA_between,xROIs_RT_between,'Type','Spearman');

[RHO_xROIs_DMPFC_within,PVAL_xROIs_within] = corr(xROIs_DMPFC_CA_within,xROIs_RT_within,'Type','Spearman');
[RHO_xROIs_DMPFC_between,PVAL_xROIs_between] = corr(xROIs_DMPFC_CA_between,xROIs_RT_between,'Type','Spearman');

[RHO_xROIs_control_within,PVAL_xROIs_within] = corr(xROIs_control_CA_within,xROIs_RT_within,'Type','Spearman');
[RHO_xROIs_control_between,PVAL_xROIs_between] = corr(xROIs_control_CA_between,xROIs_RT_between,'Type','Spearman');


All_rhos =  [RHO_xROIs_Core_within RHO_xROIs_Core_between;...
             RHO_xROIs_MTL_within RHO_xROIs_MTL_between;...
             RHO_xROIs_DMPFC_within RHO_xROIs_DMPFC_between;...
             RHO_xROIs_MD_within RHO_xROIs_MD_between;...
             RHO_xROIs_control_within RHO_xROIs_control_between];


%%


A = xROIs_RT_within;
B = xROIs_Core_CA_within;
C = xROIs_RT_between;
D = xROIs_Core_CA_between;

% core: [1 0.65 0],[1 0.95 0]
% MTL: [0 0.95 0],[0 0.65 0.]
% DMPFC: [0 0.05 0.65],[0.2 0.3 1]

s1 = repmat(80,[length(A) 1]);
s2 = repmat(80,[length(D) 1]);
c1 = repmat(8,[length(A) 1]);
c2 = repmat(5,[length(D) 1]);

figure(1)
hold on

h1 = scatter(C,D,s2',[0.2 0.3 1],'fill');
h2 =scatter(A,B,s1',[0 0.05 0.65],'fill');



axes = [0 1200 0 100];
axis(axes)
set(gca,'XTick',0:300:1200)

whitebg('w')

Xlabel = xlabel('response time (ms)');
Ylabel = ylabel('classification accuracy');

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

hold off


%%


RT_all_v = reshape(RT_all,dims,1);
RT_within_v = reshape(RT_within,(dims./5),1);
RT_between_v = reshape(RT_between,(4*dims./5),1);

CA_all_v = reshape(CA_all,dims,1);
CA_within_v = reshape(CA_within,(dims./5),1);
CA_between_v = reshape(CA_between,(4*dims./5),1);

RT_all_v(isnan(RT_all_v)) = [];
RT_within_v(isnan(RT_within_v)) = [];
RT_between_v(isnan(RT_between_v)) = [];
CA_all_v(isnan(CA_all_v)) = [];
CA_within_v(isnan(CA_within_v)) = [];
CA_between_v(isnan(CA_between_v)) = [];

[RHO_all,PVAL_all] = corr(CA_all_v,RT_all_v,'Type','Spearman');
[RHO_within,PVAL_within] = corr(CA_within_v,RT_within_v,'Type','Spearman');
[RHO_between,PVAL_between] = corr(CA_between_v,RT_between_v,'Type','Spearman');


figure(15);
scatter(CA_all_v,abs(RT_all_v),'.');

figure(16)
scatter(CA_within_v,abs(RT_within_v),'.');

figure(17)
scatter(CA_between_v,abs(RT_between_v),'.');





