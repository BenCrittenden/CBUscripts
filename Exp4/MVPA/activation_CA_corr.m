%correlation between activation differences and decoding CA

roishort = {'L_ACC','L_AI','L_APFC','L_Amyg','L_DLPFC','L_IFJ','L_IPS','L_Vis',...
            'R_ACC','R_AI','R_APFC','R_Amyg','R_DLPFC','R_IFJ','R_IPS','R_Vis'};

taskpairs = {NaN,'12','13','14','15','16',...
             '21',NaN,'23','24','25','26',...
             '31','32',NaN,'34','35','36',...
             '41','42','43',NaN,'45','46',...
             '51','52','53','54',NaN,'56',...
             '61','62','63','64','65',NaN};
         
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

    %choose the task pair
    for tasknum = 1:length(taskpairs)
        
        currentTasks = taskpairs{tasknum};        
        

        if ~isnan(currentTasks)
        %get the activation difference from all subs
        
        activation_vector = Activation_pairs(currentROI,currentTasks);
        
        AVmean = mean(abs(activation_vector));
        AVsd = std(abs(activation_vector));
        
        Zactivation_vector = (abs(activation_vector) - AVmean) / AVsd;
        

        %get the CA from all subs
        
        CA_vector = MVPA_CApairs(currentROI,currentTasks)';
       
        CAmean = mean(CA_vector);
        CAsd = std(CA_vector);
        
        ZCA_vector = (CA_vector - CAmean) / CAsd;
        
%         scatter(activation_vector,CA_vector);


        %correlate and regression of activation difference and CA
        [corr_rho,pval] = corr(abs(activation_vector),CA_vector,'type','Spearman');
        r2 = corr_rho^2;
        
        reg_beta = polyfit(abs(activation_vector),CA_vector,1);
        reg_beta = reg_beta(1);


        else
            
            corr_rho = NaN;
            reg_beta = NaN;    
            r2 = NaN;
            activation_vector = NaN;
            
        end
        
        %save value to a matrix.
        
        mat_row = ceil(tasknum / 6);
        mat_col = ((ROInum -1)*6) + tasknum - ((mat_row-1)*6);
        
        corr_supermatrix(mat_row,mat_col) = corr_rho;
        reg_supermatrix(mat_row,mat_col) = reg_beta;
        goodness_supermatrix(mat_row,mat_col) = r2;
        mean_activation_diff(mat_row,mat_col) = mean(activation_vector);

    end

end

figure(1);
imagesc(corr_supermatrix);
% save('corr_matrix','corr_supermatrix');
axis off; axis image;

figure(2);
imagesc(reg_supermatrix);
% save('reg_matrix','reg_supermatrix');
axis off; axis image;


figure(3);
imagesc(goodness_supermatrix*100);
% save('goodness_matrix','goodness_supermatrix')
axis off; axis image;

figure(4)
imagesc(mean_activation_diff);
% save('mean_activation_diff','mean_activation_diff');
axis off; axis image;

