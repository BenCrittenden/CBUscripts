%function VDT_addcontrasts(subs)

clear
spm_defaults; 
addpath('/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4');

res_dir = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/NonSmoothed/noSM_SwitchsAndTasks';
if exist(res_dir,'dir')~=7;
    mkdir(res_dir);
end

subs={'CBU120564','CBU120565','CBU120566','CBU120567','CBU120595',...
      'CBU120597','CBU120602','CBU120609','CBU120612','CBU120615',...
      'CBU120618','CBU120620','CBU120625','CBU120626','CBU120628',...
      'CBU121074','CBU121075','CBU121076'};
  
%   

for sub = 1:length(subs)
    
    csub = subs{sub};
    anadir = fullfile(res_dir, csub);
    spmfile = fullfile(anadir, 'SPM.mat');
    load(spmfile);
    
    z = zeros(1,17);
    
%set up contrasts
    cons(1).name = 'shoebox_none';
    cons(1).type = 'T';
    cons(1).vector = [1 z 1 z 1 z 1 repmat([0],1,17) 0 0 0 0];

    cons(2).name = 'shoebox_within';
    cons(2).type = 'T';
    cons(2).vector = [repmat([0],1,1) 1 z 1 z 1 z 1 repmat([0],1,16) 0 0 0 0];
    
    cons(3).name = 'shoebox_between';
    cons(3).type = 'T';
    cons(3).vector = [repmat([0],1,2)  1 z 1 z 1 z 1 repmat([0],1,15) 0 0 0 0];
    
    cons(4).name = 'living_none';
    cons(4).type = 'T';
    cons(4).vector = [repmat([0],1,3) 1 z 1 z 1 z 1 repmat([0],1,14) 0 0 0 0];
    
    cons(5).name = 'living_within';
    cons(5).type = 'T';
    cons(5).vector = [repmat([0],1,4) 1 z 1 z 1 z 1 repmat([0],1,13) 0 0 0 0];
    
    cons(6).name = 'living_between';
    cons(6).type = 'T';
    cons(6).vector = [repmat([0],1,5) 1 z 1 z 1 z 1 repmat([0],1,12) 0 0 0 0];
    
    cons(7).name = 'shapes_none';
    cons(7).type = 'T';
    cons(7).vector = [repmat([0],1,6) 1 z 1 z 1 z 1 repmat([0],1,11) 0 0 0 0];
    
    cons(8).name = 'shpaes_within';
    cons(8).type = 'T';
    cons(8).vector = [repmat([0],1,7) 1 z 1 z 1 z 1 repmat([0],1,10) 0 0 0 0];
    
    cons(9).name = 'shapes_between';
    cons(9).type = 'T';
    cons(9).vector = [repmat([0],1,8) 1 z 1 z 1 z 1 repmat([0],1,9) 0 0 0 0];
    
    cons(10).name = 'size_none';
    cons(10).type = 'T';
    cons(10).vector = [repmat([0],1,9) 1 z 1 z 1 z 1 repmat([0],1,8) 0 0 0 0];
    
    cons(11).name = 'size_within';
    cons(11).type = 'T';
    cons(11).vector = [repmat([0],1,10) 1 z 1 z 1 z 1 repmat([0],1,7) 0 0 0 0];
    
    cons(12).name = 'size_between';
    cons(12).type = 'T';
    cons(12).vector = [repmat([0],1,11) 1 z 1 z 1 z 1 repmat([0],1,6) 0 0 0 0];
    
    cons(13).name = 'A_none';
    cons(13).type = 'T';
    cons(13).vector = [repmat([0],1,12) 1 z 1 z 1 z 1 repmat([0],1,5) 0 0 0 0];
    
    cons(14).name = 'A_within';
    cons(14).type = 'T';
    cons(14).vector = [repmat([0],1,13) 1 z 1 z 1 z 1 repmat([0],1,4) 0 0 0 0];
    
    cons(15).name = 'A_between';
    cons(15).type = 'T';
    cons(15).vector = [repmat([0],1,14) 1 z 1 z 1 z 1 repmat([0],1,3) 0 0 0 0];
    
    cons(16).name = 'I_none';
    cons(16).type = 'T';
    cons(16).vector = [repmat([0],1,15) 1 z 1 z 1 z 1 repmat([0],1,2) 0 0 0 0];
    
    cons(17).name = 'I_within';
    cons(17).type = 'T';
    cons(17).vector = [repmat([0],1,16) 1 z 1 z 1 z 1 repmat([0],1,1) 0 0 0 0];
    
    cons(18).name = 'I_between';
    cons(18).type = 'T';
    cons(18).vector = [repmat([0],1,17) 1 z 1 z 1 z 1 0 0 0 0];

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