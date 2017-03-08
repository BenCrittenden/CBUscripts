%correlation between activation differences and decoding CA

roishort = {'L_HF','L_PHC','L_PPC','L_Rsp','L_TPJ','L_TempP','L_aMPFC','L_pIPL',...
    'R_HF','R_LTC','R_PHC','R_PCC','R_Rsp','R_TPJ','R_aMPFC','R_pIPL',...
    'dMPFC','vMPFC'}; %,'L_LTC','R_TempP'

% roishort = {'L_ACC','L_AI','L_APFC','L_Amyg','L_DLPFC','L_IFJ','L_IPS','L_Vis',...
%             'R_ACC','R_AI','R_APFC','R_Amyg','R_DLPFC','R_IFJ','R_IPS','R_Vis'};

% taskpairs = {NaN,'12','13','14','15','16',...
%              '21',NaN,'23','24','25','26',...
%              '31','32',NaN,'34','35','36',...
%              '41','42','43',NaN,'45','46',...
%              '51','52','53','54',NaN,'56',...
%              '61','62','63','64','65',NaN};

taskpairs = {'21',...
             '31','32',...
             '41','42','43',...
             '51','52','53','54',...
             '61','62','63','64','65'};         


num_rows = 6;
num_cols = 6*16;
         
corr_supermatrix = NaN(num_rows,num_cols);
reg_supermatrix = corr_supermatrix;
goodness_supermatrix = corr_supermatrix;
mean_activation_diff = corr_supermatrix;
         
%choose the ROI
for ROInum = 1:length(roishort)
    
    currentROI = roishort{ROInum};
    display(currentROI())
    
    ROI_CAvector = [];
    ROI_RTvector = [];
    ROI_ACTvector = [];

    %choose the task pair
    for tasknum = 1:length(taskpairs)
        
        currentTasks = taskpairs{tasknum};        
        

        if ~isnan(currentTasks)
        %get the activation difference from all subs
        
        activation_vector = Activation_pairs(currentROI,currentTasks);
        
        AVmean = mean(abs(activation_vector));
        AVsd = std(abs(activation_vector));
        
        Zactivation_vector = (abs(activation_vector) - AVmean) / AVsd;
        
        %get RT difference from all subs
%         RT_vector = Get_RT(currentTasks);
%         
%         RT_vector = RT_vector';
%         RT_hardertask = length(RT_vector(RT_vector>0));
%                       
%         RTmean = mean(abs(RT_vector));
%         RTsd = std(abs(RT_vector));                
%         ZRT_vector = (abs(RT_vector) - RTmean) / RTsd;
        

        %get the CA from all subs
        
        CA_vector = MVPA_CApairs(currentROI,currentTasks)';
       
        CAmean = mean(CA_vector);
        CAsd = std(CA_vector);
        
        ZCA_vector = (CA_vector - CAmean) / CAsd;
        
        else
                      
        end
        
        ROI_ACTvector = [ROI_ACTvector abs(activation_vector)];
        ROI_CAvector = [ROI_CAvector CA_vector];
%         ROI_RTvector = [ROI_RTvector abs(RT_vector)];

    end
    
    ROI_CAvector = reshape((ROI_CAvector + 50),[],1);
    ROI_ACTvector = reshape(ROI_ACTvector,[],1);
%     ROI_RTvector = reshape(ROI_RTvector,[],1);
    
%     ZROI_ACTvector = (abs(ROI_ACTvector) - mean(abs(ROI_ACTvector))) / std(abs(ROI_ACTvector));
%     ZROI_CAvector = (ROI_CAvector - mean(ROI_CAvector)) / std(ROI_CAvector);
%     ZROI_ACTvector = (ROI_ACTvector - mean(ROI_ACTvector)) / std(ROI_ACTvector);
    ROI_ACTvector = reshape(ROI_ACTvector,[],1);
    display(max(ROI_ACTvector))
    figure(ROInum)
    f = scatter(ROI_CAvector,ROI_ACTvector,...
        'MarkerEdgeColor','b',...
        'MarkerFaceColor','g',...
        'Marker','o',...
        'LineWidth',2);
    
    bf = lsline; %line of best fit, least wquares sense
    set(bf,'Color',              [.5 .5 .5],...
      'LineWidth',          2);
    
    [rho,pval] = corr(ROI_CAvector,ROI_ACTvector,'type','Spearman');
        
    
axis([0 105 0 2.5])  %-inf and inf effectively autoscale y axis
  
ftitle = title('');
fXlabel = xlabel(''); %Classification Accuracy');
fYlabel = ylabel(''); %Difference in beta values');

set([gca ftitle fXlabel fYlabel],...
      'FontName',         'Helvetica',...
      'FontSize',         16,...
      'FontWeight',       'bold');

set(gca,...
    'Box',                  'off',...
    'TickDir',              'out',...
    'TickLength',           [0.01 0.01],...
    'XMinorTick',           'off',...
    'YMinorTick',           'off',...
    'YGrid',                'off',...
    'XGrid',                'off',...
    'XColor',               [.3 .3 .3],...
    'YColor',               [.3 .3 .3],...
    'LineWidth',             1);

rho = round(rho*100)/100;
fText = text(5,2.35,['rho = ' num2str(rho,2)]);
set(fText,...
      'FontName',         'Helvetica',...
      'FontSize',         21,...
      'FontWeight',       'bold',...
      'FontAngle',        'oblique');
  
pval = round(pval*100)/100;  
if pval < 0.001
    pText = text(5,2.2,'p < 0.001');
else
    pText = text(5,2.2,['p = ' num2str(pval,1)]);
end

set(pText,...
      'FontName',         'Helvetica',...
      'FontSize',         21,...
      'FontWeight',       'bold',...
      'FontAngle',        'oblique'); 

set(gcf, 'PaperPositionMode', 'auto');

% filenamef = ['ROIcorr_' currentROI '.jpg'];
% saveas(f,filenamef);
    
    
%     scatter3(ROI_CAvector,ROI_ACTvector,ROI_RTvector);    
%     partialcorr(ROI_CAvector,ROI_ACTvector,ROI_RTvector,'type','Spearman')
%     partialcorr(ROI_RTvector,ROI_CAvector,ROI_ACTvector,'type','Spearman')
%     partialcorr(ROI_RTvector,ROI_ACTvector,ROI_CAvector,'type','Spearman')


end

% figure(1);
% imagesc(corr_supermatrix);
% save('corr_matrix','corr_supermatrix');
% axis off; axis image;
% 
% figure(2);
% imagesc(reg_supermatrix);
% save('reg_matrix','reg_supermatrix');
% axis off; axis image;
% 
% 
% figure(3);
% imagesc(goodness_supermatrix*100);
% save('goodness_matrix','goodness_supermatrix')
% axis off; axis image;
% 
% figure(4)
% imagesc(mean_activation_diff);
% save('mean_activation_diff','mean_activation_diff');
% axis off; axis image;

