%Extract data for plotting

%Coordinate Data is stored in:
% /imaging/bc01/Experiments4_5/Nov_2012/Connectivity/Rest3/results/resultsROI_Subject001_Condition001.mat
% coordinates in the xyz field
% 

%To get 2nd-level results do:
% 
%  x = conn_process('results_roi');
% 
% the returned variable 'x' is a structure array with all of the ROI-to-ROI
% analyses (one for each source ROI). If, for example, you want to get the T-
% or F- statistics for each source/target ROI as a matrix you could simply
% type:

% y is the Z (fisher transformed correlation) for that ROI with all other
% ROIs in the columns, for all subjects (ther rows). The average across all
% subjects is given in h, (effect sizes)

%  F = cat(1,x.F);
% 
% and that will give you a number_of_sources * number_of_targets matrix 'F'
% of T-values (see below). The main fieldnames of interest to you in the 
% returned variable 'x' will probably be:
% 
%  h: effect sizes
%  F: statistics (T-, F-, or Chi-square values depending on the dimensionality
%  of your contrast vector/matrices)
%  p: p-values (one-sided for T-statistics, or two-sided for everything else)
%  dof: degrees of freedom
%  statsname: 'T' (for t-statistics), 'F' (for F-tests), 'X' (for 
%  chi-square values from Wilks' lambda tests)
%  Z


clear all

% datDir = '/imaging/bc01/Experiments4_5/Nov_2012/Connectivity/Rest3/results/firstlevel/ANALYSIS_01';
% datDir = '/imaging/bc01/Experiments4_5/Nov_2012/Connectivity/Rest4/results/firstlevel/ANALYSIS_01';
datDir = '/imaging/bc01/Experiments4_5/Nov_2012/Connectivity/Rest_residuals2/results/firstlevel/ANALYSIS_01';

data = load(fullfile(datDir,'resultsROI_Condition001.mat'));


%%
Graph = squeeze(mean(data.Z(:,[1:(end-1)],:),3));
% thresh = 0.3;
% 
% Graph(Graph<thresh)=NaN;
% 
% Graph(~isnan(Graph)) = 1;
% Graph(isnan(Graph)) = 0;

Reorder = [1 2 3 7 8 9 4 5 6 10 11 12 13 14];
corr_mat = Graph(Reorder,Reorder);

% dlmwrite('Resid_Z50.edge',corr_mat,'delimiter','\t')


%%
% figure, imagesc(corr_mat)


h = figure;
set(h,'Position', [50, 50, 1100, 900]);
imagesc(corr_mat);
caxis([-.0 0.8])
colormap(paruly)


%%
node_coords = (data.xyz(1:14))';
node_coords = num2cell(ceil(cell2mat(node_coords)));
node_colours = num2cell([1 1 1 2 2 2 1 1 1 2 2 2 3 3]');
node_sizes = num2cell(ones(length(node_coords),1));
node_names = (data.names(1:14))';

node_file = horzcat(node_coords,node_colours,node_sizes,node_names);


% dlmwrite('Rest3.edge',node_file,'delimiter','\t')
% 
% fileID = fopen('Rest3.node','w');
% formatSpec = '%d %d %d %d %d %s\n';
% 
% 
% [nrows,ncols] = size(node_file);
% for row = 1:nrows
% %     fprintf(fileID,formatSpec,node_file{row,:});
% end
% fclose(fileID);


%%

rem_COFP = [1:6;7:12];
rem_CO = [7:12;7:12];
rem_FP = [1:6;1:6];
rem_Amyg = [13 14;13 14];

corr_mat2 = corr_mat;
corr_mat2(rem_Amyg(1,:),rem_Amyg(2,:)) = NaN;
% corr_mat2(rem_COFP(1,:),rem_COFP(2,:)) = NaN;
% corr_mat2(rem_COFP(2,:),rem_COFP(1,:)) = NaN;
corr_mat2(rem_CO(2,:),rem_CO(1,:)) = NaN;
corr_mat2(rem_FP(2,:),rem_FP(1,:)) = NaN;

Graph(isnan(Graph)) = 0;
figure,imagesc(corr_mat2)

%%
dlmwrite('Resid_30_fp.edge',corr_mat2,'delimiter','\t')


%%
node_file2 = node_file(Reorder,:);

fileID = fopen('Rest3_reordered.node','w');
formatSpec = '%d %d %d %d %d %s\n';


[nrows,ncols] = size(node_file2);
for row = 1:nrows
    fprintf(fileID,formatSpec,node_file2{row,:});
end
fclose(fileID);


%%

%Percent of between-conns intact
nansum(nansum(corr_mat2)./2)./(36)

%Percent of FP/CO intact
nansum(nansum(corr_mat2)./2)./(15)

%% Average con

group_graph = data.Z(1:14,1:14,:);
Reorder = [1 2 3 7 8 9 4 5 6 10 11 12 13 14];

a = size(group_graph,1);

%including hemishperic pairs
% FPsqrs = [2:6 a+(3:6) 2*a+(4:6) 3*a+(5:6) 4*a+6]';
% COsqrs = [6*a+(8:12) 7*a+(9:12) 8*a+(10:12) 9*a+(11:12) 10*a+(12)]';
% bothsqrs = [7:12 a+(7:12) 2*a+(7:12) 3*a+(7:12) 4*a+(7:12) 5*a+(7:12)]';

%excluding hemishperic pairs
FPsqrs = [[2 3 5 6] a+([3 4 6]) 2*a+(4:5) 3*a+(5:6) 4*a+6]';
COsqrs = [6*a+([8 9 11 12]) 7*a+([9 10 12]) 8*a+([10 11]) 9*a+(11:12) 10*a+(12)]';
bothsqrs = [7:12 a+(7:12) 2*a+(7:12) 3*a+(7:12) 4*a+(7:12) 5*a+(7:12)]';

for subj = 1:size(group_graph,3)
    
    clear gg
    gg = squeeze(group_graph(:,:,subj));
    gg = gg(Reorder,Reorder);
    
    FPavg(subj) = nanmean(gg(FPsqrs));
    COavg(subj) = nanmean(gg(COsqrs));
    bothavg(subj) = nanmean(gg(bothsqrs));

end

m(2) = mean(FPavg)
m(1) = mean(COavg)
m(3) = mean(bothavg)

[~,p] = ttest(FPavg,bothavg,0.05,'right')
[~,p] = ttest(COavg,bothavg,0.05,'right')
[~,p] = ttest(COavg,FPavg,0.05,'both')

figure,
hold on
bar(m)
axis([-inf inf 0 0.60])
set(gca,'XTick',1:3,'XTickLabel',{'CO','FP','between'})
hold off

%% The list of ROIs and in the reoredered order if you want.

roiNames = {'R_Par','R_IFJ','R_DLPFC','R_APFC','R_AI','R_ACC',...
    'L_Par','L_IFJ','L_DLPFC','L_APFC','L_AI','L_ACC',...
    'R_Amyg','L_Amyg'};

roiNames(Reorder)


