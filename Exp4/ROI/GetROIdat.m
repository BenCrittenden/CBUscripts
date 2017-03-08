clear all

load('/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/ROI/DM_SpecificSwitches_ROIres/roi_results1.mat')

betas = res.beta;
betas = cell2mat(betas);
betas = reshape(betas,[10,4,20,17]);

betas(betas > 10 | betas <-10) = NaN;

% 
% roishort = {'L_HF','L_LTC','L_PCC','L_PHC','L_Rsp','L_TPJ','L_TempP','L_aMPFC','L_pIPL',...
%     'R_HF','R_LTC','R_PCC','R_PHC','R_Rsp','R_TPJ','R_TempP','R_aMPFC','R_pIPL',...
%     'dMPFC','vMPFC'};

MTL_rois = betas(:,:,[1 4 5 9 10 13 14 18 20],:);
DMPFC_rois = betas(:,:,[2 6 7 11 15 16 19],:);
Core_rois = betas(:,:,[3 8 12 17],:);

MTL_sys = squeeze(nanmean(nanmean(MTL_rois,2),3));
DMPFC_sys = squeeze(nanmean(nanmean(DMPFC_rois,2),3));
Core_sys = squeeze(nanmean(nanmean(Core_rois,2),3));

for tp = 1:6
    
    switch tp
        case 1
            MTL(tp,:) = MTL_sys(tp,:) - MTL_sys(8,:);
            DMPFC(tp,:) = DMPFC_sys(tp,:) - DMPFC_sys(8,:);
            Core(tp,:) = Core_sys(tp,:) - Core_sys(8,:);
        case 2
            MTL(tp,:) = MTL_sys(tp,:) - MTL_sys(8,:);
            DMPFC(tp,:) = DMPFC_sys(tp,:) - DMPFC_sys(8,:);
            Core(tp,:) = Core_sys(tp,:) - Core_sys(8,:);
        case 3
            MTL(tp,:) = MTL_sys(tp,:) - MTL_sys(9,:);
            DMPFC(tp,:) = DMPFC_sys(tp,:) - DMPFC_sys(9,:);
            Core(tp,:) = Core_sys(tp,:) - Core_sys(9,:);
        case 4
            MTL(tp,:) = MTL_sys(tp,:) - MTL_sys(9,:);
            DMPFC(tp,:) = DMPFC_sys(tp,:) - DMPFC_sys(9,:);
            Core(tp,:) = Core_sys(tp,:) - Core_sys(9,:);
        case 5
            MTL(tp,:) = MTL_sys(tp,:) - MTL_sys(10,:);
            DMPFC(tp,:) = DMPFC_sys(tp,:) - DMPFC_sys(10,:);
            Core(tp,:) = Core_sys(tp,:) - Core_sys(10,:);
        case 6
            MTL(tp,:) = MTL_sys(tp,:) - MTL_sys(10,:);
            DMPFC(tp,:) = DMPFC_sys(tp,:) - DMPFC_sys(10,:);
            Core(tp,:) = Core_sys(tp,:) - Core_sys(10,:);
    end
    
end

MTL = mean(MTL,2);
DMPFC = mean(DMPFC,2);
Core = mean(Core,2);

figure,
hold on
plot(MTL,'g')
plot(DMPFC,'b')
plot(Core,'r')
hold off


display('done')

