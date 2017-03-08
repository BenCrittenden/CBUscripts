%create an conditions array


rootdir = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/MVPA/WholeBrain/Zx-Results';

subs = {'CBU120564','CBU120565','CBU120566','CBU120567','CBU120595',...
      'CBU120597','CBU120602','CBU120609','CBU120612','CBU120615',...
      'CBU120618','CBU120620','CBU120625','CBU120626','CBU120628',...
      'CBU121074','CBU121075','CBU121076'};
  
for sub = 1:length(subs)  

    subdir = fullfile(rootdir,subs{sub});
    img_file = 'res_accuracy_minus_chance.img';
    hdr_file = 'res_accuracy_minus_chance.hdr';

    for task = 1:6
        
        con_folder = dir(fullfile(subdir,['*' num2str(task) '*']));
    
        images2slice = {fullfile(subdir,con_folder(1).name,img_file);...
                fullfile(subdir,con_folder(2).name,img_file);...
                fullfile(subdir,con_folder(3).name,img_file);...
                fullfile(subdir,con_folder(4).name,img_file);...
                fullfile(subdir,con_folder(5).name,img_file)};
            
        spm_reslice(images2slice,struct('which',0));
 
        % move the newly created file to a more convenient directory
        
        %file origin and destination
        imgfile_origin = fullfile(subdir,con_folder(1).name,['mean' img_file]);
        hdrfile_origin = fullfile(subdir,con_folder(1).name,['mean' hdr_file]);
        
        file_dest = fullfile(subdir,'decoded_means',['decoded_' num2str(task)]);
        if exist(file_dest,'dir')~=7;mkdir(file_dest);end
        
        movefile(imgfile_origin,file_dest);
        movefile(hdrfile_origin,file_dest);
        
        display(['task = ' num2str(task)])
        
    end
 
        display(subs{sub})

end

display('done, Done, DONE!')
