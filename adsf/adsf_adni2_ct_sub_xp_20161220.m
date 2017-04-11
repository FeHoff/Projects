%% script to subtype on whole brain cortical thickness in just adni2

clear all

%% perform subtyping/clustering

path_c = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/';

files_in.data = [path_c 'adni2/adni2_civet_vertex_stack_r_20170122.mat'];
files_in.mask = [path_c 'mask_whole_brain.mat'];
files_out = struct;
opt.folder_out = [path_c 'adni2/wb_ct_subtypes_20170122/'];
psom_mkdir(opt.folder_out);
opt.nb_subtype = 3;

adsf_brick_subtyping(files_in,files_out,opt);

%% visualization for subtypes

clear all

files_in = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/adni2/wb_ct_subtypes_20170122/subtype.mat';
files_out = struct;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/adni2/wb_ct_subtypes_20170122/';
opt.nb_subtype = 3;

adsf_brick_visu_ct_sub(files_in,files_out,opt);

%% calculate weights for subjects

clear all

path_c = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/';

files_in.data.wb = [path_c 'adni2/adni2_civet_vertex_stack_r_20170122.mat'];
files_in.subtype.wb = [path_c 'adni2/wb_ct_subtypes_20170122/subtype.mat'];
files_out = struct;
opt.folder_out = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/adni2/wb_ct_subtypes_20170122/';

adsf_brick_subtype_weight(files_in,files_out,opt);

%% script to test variables (diagnosis, amyloid...) on weights
clear all

path_c = '/Users/AngelaTam/Desktop/adsf/ct_subtypes/adni2/';
files_in.weight = [path_c 'wb_ct_subtypes_20170122/subtype_weights.mat'];
files_in.model = '/Users/AngelaTam/Desktop/adsf/adni2_weights_vbm_rs_ct_model.csv';

vars = {'AV45','FDG','ADAS11','MMSE','MOCA','EcogPtTotal','EcogSPTotal'};
%vars = {'diagnosis','APOE4_status'};

for ss = 1:length(vars)
    clear opt
    
    field = vars{ss};
    
    files_out = struct;
    opt.folder_out = strcat(path_c, 'wb_ct_subtypes_20170122/', field, filesep);
    psom_mkdir(opt.folder_out);
    opt.scale = 1;
    opt.contrast.age = 0;
    opt.contrast.mtladni2sites = 0;
    opt.contrast.mean_ct_wb = 0;
    opt.contrast.gender = 0;
    %opt.contrast.diagnosis = 0;
    
    opt.contrast.(field) = 1;
    
    niak_brick_association_test(files_in,files_out,opt);
    opt.data_type = 'continuous';
    files_in.association = strcat(path_c, 'wb_ct_subtypes_20170122/', field, filesep, 'association_stats.mat');
    adsf_brick_visu_subtype_glm(files_in,files_out,opt);
    
end









