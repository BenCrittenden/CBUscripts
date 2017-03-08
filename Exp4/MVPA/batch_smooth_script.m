%smoothing script


FWHM = [6 6 6];

mask_dir = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/NonSmoothed/noSM_Tasks';
data_root_dir = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/MVPA';
results_root_dir = '/imaging/bc01/Experiments4_5/Nov_2012/Experiment_4/MVPA/WholeBrain/Zx-Results/Smoothed';

subs={'CBU120564','CBU120565','CBU120566','CBU120567','CBU120595',...
      'CBU120597','CBU120602','CBU120609','CBU120612','CBU120615',...
      'CBU120618','CBU120620','CBU120625','CBU120626','CBU120628',...
      'CBU121074','CBU121075','CBU121076'};

for folder_num = 1:6
    
    display(folder_num)
    
    save_folder = [results_root_dir '/' num2str(folder_num)];
    if exist(save_folder,'dir')~=7;mkdir(save_folder);end
    
    for s = 1:length(subs)
        
               
        tobesmoothed = [data_root_dir '/WholeBrain/Zx-Results/' subs{s} '/decoded_means/decoded_' num2str(folder_num) '/meanres_accuracy_minus_chance.img'];
        newimage = [data_root_dir '/WholeBrain/Zx-Results/' subs{s} '/decoded_means/decoded_' num2str(folder_num) '/SMmeanres_accuracy_minus_chance.img'];
         
         spm_smooth(tobesmoothed,newimage,FWHM);
         
         %get the subs original mask, to remove activation outside the
         %brain due to smoothing
         
         mask_img_dir = [mask_dir '/' subs{s} '/mask.img'];
                                  
         smoothed_img = spm_read_vols(spm_vol(newimage));
         mask_img = spm_read_vols(spm_vol(mask_img_dir));
         
         details = spm_vol(newimage);
         details.fname = [save_folder '/MSK_SM_' subs{s} '.img'];
         details.descrip = [details.descrip '_masked'];
         
         combined = mask_img .* smoothed_img;
         
         spm_write_vol(details,combined);
                 
                        
         display(subs{s})
         
    end
    
       
end