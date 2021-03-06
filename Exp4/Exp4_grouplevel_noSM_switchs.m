%-----------------------------------------------------------------------
%Design specific parameters
%-----------------------------------------------------------------------
clear

subs = {'CBU120564','CBU120565','CBU120566','CBU120567','CBU120595',...
      'CBU120597','CBU120602','CBU120609','CBU120612','CBU120615',...
      'CBU120618','CBU120620','CBU120625','CBU120626','CBU120628',...
      'CBU121074','CBU121075','CBU121076'};

nsubs = length(subs);

statsdir = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/NonSmoothed/noSM_Switchs';
rfxdir = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/NonSmoothed/noSM_Switchs/Group';
if exist(rfxdir,'dir')~=7;
    mkdir(rfxdir);
end

cons = 1:6;
ncons = size(cons,2);

con_img_type = repmat({'con'},1,ncons);

SPM = load(fullfile(statsdir,subs{1,1},'SPM.mat'));
connames = char(SPM.SPM.xCon.name);

%-----------------------------------------------------------------------
%Design setup
%-----------------------------------------------------------------------
jobs = cell(1);
job=[];
job.cov = struct('c',{},'cname',{},'iCFI',{},'iCC',{});

%no threshold masking
tm = struct('tm_none',[]);

%relative threshold masking
%tm.tmr.rthresh = 0.1;

%absolute threshold masking
%tm.tma.athresh = 0;

expmask=''; % no explicit mask
%expmask = vm.fname; %explicit mask
job.masking = struct('tm',tm,'im',1,'em',{{expmask}});


job.globalc = struct('g_omit',[]);
gmsca = struct('gmsca_no',[]);
job.globalm = struct('gmsca',gmsca,'glonorm',1);




for con = 1:ncons
    cconname = strrep(deblank(connames(con,:)),' - ','-');
    cconname = strrep(cconname,',','');
    cconname = strrep(cconname,' ','_');
    
    condir = fullfile(rfxdir,cconname);
    if ~exist(condir,'dir');mkdir(condir);end
    cd(condir)
    
    job.dir = {condir};
    job.des.t1.scans = cell(1,nsubs);

    for s=1:nsubs
        img = num2str(cons(con));
        img = fullfile(statsdir,subs{s},[con_img_type{con} '_' repmat('0',1,4-length(img)) img '.img']);
        if exist(img,'file')==2
            job.des.t1.scans{s} = img;
        else
            error(['Can''t find image ' img]);
        end
    end

    jobs{1}.stats{1}.factorial_design = job;

    % run design
    spm_unlink(fullfile('.', 'mask.img')); % avoid overwrite dialog
    spm_jobman('run',jobs); % set up design mat file
    load 'SPM.mat';
    SPM = spm_spm(SPM); % estimate design

    % do contrast
    cc = spm_FcUtil('Set',deblank(connames(con,:)),'T','c',1,SPM.xX.xKXs);
    if isfield(SPM,'xCon') && isempty(SPM.xCon)==false
        SPM.xCon(end+1) = cc;
    else
        SPM.xCon = cc;
    end
    spm_contrasts(SPM);
end
