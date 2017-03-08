clear all

load('/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/ROI/DM_SpecificSwitches_ROIres2/roi_results1.mat')

betas = res.beta;
betas = cell2mat(betas);
betas = reshape(betas,[36,4,20,18]);

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


for st = 1:6

    %     evshort = {1'sem1-sem1','sem1-sem2','sem1-per1','sem1-per2','sem1-lex1','sem1-lex2',...
    %            7'sem2-sem1','sem2-sem2','sem2-per1','sem2-per2','sem2-lex1','sem2-lex2',...
    %            13 'per1-sem1','per1-sem1','per1-per1','per1-per2','per1-lex1','per1-lex2',...
    %             19'per2-sem1','per2-sem2','per2-per1','per2-per2','per2-lex1','per2-lex2',...
    %             25'lex1-sem1','lex1-sem1','lex1-per1','lex1-per2','lex1-lex1','lex1-lex2',...
    %             31'lex2-sem1','lex2-sem2','lex2-per1','lex2-per2','lex2-lex1','lex2-lex2'};

    switch st
        case 1
            tp3 = [3 4 9 10];
        case 2
            tp3 = [5 6 11 12];
        case 3
            tp3 = [13 14 19 20];
        case 4
            tp3 = [17 18 23 24];
        case 5
            tp3 = [25 26 31 32];
        case 6
            tp3 = [27 28 33 34];
    end

    for tp = 1:length(tp3)
        
        tp2 = tp3(tp);

        switch tp2
            case {13 19 25 31}
                MTL(tp2,:) = MTL_sys(tp2(1),:) - MTL_sys(1,:);
                DMPFC(tp2,:) = DMPFC_sys(tp2,:) - DMPFC_sys(1,:);
                Core(tp2,:) = Core_sys(tp2,:) - Core_sys(1,:);
            case {14 20 26 32}
                MTL(tp2,:) = MTL_sys(tp2,:) - MTL_sys(8,:);
                DMPFC(tp2,:) = DMPFC_sys(tp2,:) - DMPFC_sys(8,:);
                Core(tp2,:) = Core_sys(tp2,:) - Core_sys(8,:);
            case {3 9 27 33}
                MTL(tp2,:) = MTL_sys(tp2,:) - MTL_sys(15,:);
                DMPFC(tp2,:) = DMPFC_sys(tp2,:) - DMPFC_sys(15,:);
                Core(tp2,:) = Core_sys(tp2,:) - Core_sys(15,:);
            case {4 10 28 34}
                MTL(tp2,:) = MTL_sys(tp2,:) - MTL_sys(22,:);
                DMPFC(tp2,:) = DMPFC_sys(tp2,:) - DMPFC_sys(22,:);
                Core(tp2,:) = Core_sys(tp2,:) - Core_sys(22,:);
            case {5 11 17 23}
                MTL(tp2,:) = MTL_sys(tp2,:) - MTL_sys(29,:);
                DMPFC(tp2,:) = DMPFC_sys(tp2,:) - DMPFC_sys(29,:);
                Core(tp2,:) = Core_sys(tp2,:) - Core_sys(29,:);
            case {6 12 18 24}
                MTL(tp2,:) = MTL_sys(tp2,:) - MTL_sys(36,:);
                DMPFC(tp2,:) = DMPFC_sys(tp2,:) - DMPFC_sys(36,:);
                Core(tp2,:) = Core_sys(tp2,:) - Core_sys(36,:);
        end


    end

end

for st = 1:6
    
    switch st
        case 1
            mtl(st,:,:) = MTL([3 4 9 10],:);
            dmpfc(st,:,:) = DMPFC([3 4 9 10],:);
            core(st,:,:) = Core([3 4 9 10],:);
        case 2
            mtl(st,:,:) = MTL([5 6 11 12],:);
            dmpfc(st,:,:) = DMPFC([5 6 11 12],:);
            core(st,:,:) = Core([5 6 11 12],:);
        case 3
            mtl(st,:,:) = MTL([13 14 19 20],:);
            dmpfc(st,:,:) = DMPFC([13 14 19 20],:);
            core(st,:,:) = Core([13 14 19 20],:);
        case 4
            mtl(st,:,:) = MTL([17 18 23 24],:);
            dmpfc(st,:,:) = DMPFC([17 18 23 24],:);
            core(st,:,:) = Core([17 18 23 24],:);
        case 5
            mtl(st,:,:) = MTL([25 26 31 32],:);
            dmpfc(st,:,:) = DMPFC([25 26 31 32],:);
            core(st,:,:) = Core([25 26 31 32],:);
        case 6
            mtl(st,:,:) = MTL([27 28 33 34],:);
            dmpfc(st,:,:) = DMPFC([27 28 33 34],:);
            core(st,:,:) = Core([27 28 33 34],:);            
    end
    
    
end

MTLex = squeeze(nanmean(mtl,2));
DMPFCex = squeeze(nanmean(dmpfc,2));
Coreex = squeeze(nanmean(core,2));


MTLm = squeeze(nanmean(nanmean(mtl,2),3));
DMPFCm = squeeze(nanmean(nanmean(dmpfc,2),3));
Corem = squeeze(nanmean(nanmean(core,2),3));

figure,
hold on
plot(MTLm,'g')
plot(DMPFCm,'b')
plot(Corem,'r')
hold off


display('done')

