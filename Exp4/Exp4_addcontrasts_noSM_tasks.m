%function VDT_addcontrasts(subs)

clear
spm_defaults; 
addpath('/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4');

res_dir = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/NonSmoothed/noSM_Tasks';
if exist(res_dir,'dir')~=7;
    mkdir(res_dir);
end

subs={'CBU120564','CBU120565','CBU120566','CBU120567','CBU120595',...
      'CBU120597','CBU120602','CBU120609','CBU120612','CBU120615',...
      'CBU120618','CBU120620','CBU120625','CBU120626','CBU120628',...
      'CBU121074','CBU121075','CBU121076'};

for sub = 1:length(subs)
    
    csub = subs{sub};
    anadir = fullfile(res_dir, csub);
    spmfile = fullfile(anadir, 'SPM.mat');
    load(spmfile);
    
    
    
%set up contrasts
    cons(1).name = 'shoebox-base';
    cons(1).type = 'T';
    cons(1).vector = [1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0];

    cons(2).name = 'living-base';
    cons(2).type = 'T';
    cons(2).vector = [0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0];
    
    cons(3).name = 'shapes-base';
    cons(3).type = 'T';
    cons(3).vector = [0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0];
    
    cons(4).name = 'size-base';
    cons(4).type = 'T';
    cons(4).vector = [0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0];
    
    cons(5).name = 'lett_A-base';
    cons(5).type = 'T';
    cons(5).vector = [0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0];
    
    cons(6).name = 'lett_I-base';
    cons(6).type = 'T';
    cons(6).vector = [0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0];
    
    cons(7).name = 'all-base';
    cons(7).type = 'T';
    cons(7).vector = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0];

    for i = 1:size(cons,2)
        if isempty(SPM.xCon)
            SPM.xCon = spm_FcUtil('Set',cons(i).name,cons(i).type,'c',cons(i).vector',SPM.xX.xKXs);
            %SPM.xCon = spm_FcUtil('Set',cname{i},'T','c',cons{i}',SPM.xX.xKXs);
        else
            SPM.xCon(end+1) = spm_FcUtil('Set',cons(i).name,cons(i).type,'c',cons(i).vector',SPM.xX.xKXs);
        end
        
    end
    
    spm_contrasts(SPM);
    
end