clear

%% This script will download and extract some data in the current folder, if it can't find an archive called cambridge_24_subjects_tseries.zip
%% It will also generate a number of figures and volumes
%% Please execute in a dedicated folder

%% Download example time series
if ~psom_exist('cambridge_24_subjects_tseries.zip')
    system('wget http://www.nitrc.org/frs/download.php/6779/cambridge_24_subjects_tseries.zip')
    system('unzip cambridge_24_subjects_tseries.zip')
end

%% build the average group connectome
list_files = dir([pwd filesep 'cambridge_24_subjects_tseries' filesep 'tseries_rois_*_session1_rest.mat']);
list_files = {list_files.name};
for ss = 2:length(list_files)
    data = load([pwd filesep 'cambridge_24_subjects_tseries' filesep list_files{ss}]);
    tseries = data.tseries;
    if ss == 2
        Rg = corr(tseries);
    else
        Rg = Rg + corr(tseries);
    end
end
Rg = Rg / (length(list_files)-1);

%% Now apply a hierarchical clustering on the average R to generate some group partition, with 8 clusters
hier_g = niak_hierarchical_clustering(Rg); % the hierarchical clustering
opt_t.thresh = 8; % option to extract the partition (number of clusters)
part_g = niak_threshold_hierarchy(hier_g,opt_t); % extract the partition
[hdr,rois] = niak_read_vol([pwd filesep 'cambridge_24_subjects_tseries' filesep 'brain_rois.nii.gz']); % read the rois that correspond to the columns of R
vol_part = niak_part2vol(part_g,rois); % build a volumetric version of the partition
hf = figure; % do a montage of the partition
niak_montage(vol_part)
print('montage_scale8_group.png','-dpng');
hdr.file_name = 'partition_scale8_group.nii.gz'; % save the partition in a nifti file
niak_write_vol(hdr,vol_part); 

%% Let's now use this group clustering as a prior to decompose the data from subject 1 into clusters
data = load([pwd filesep 'cambridge_24_subjects_tseries' filesep list_files{1}]); % load time series of subject 1
tseries = data.tseries;
% set the options for the s-cores
opt_scores.sampling.type = 'window';
opt_scores.sampling.opt.length = size(tseries,1); % use a time window of the same length of the time series
res = niak_stability_scores_v2(tseries,part_g,opt_scores);

%% Let's make a figure with the average connectome of all subjects, the partition in ten clusters at the group level
%% and then the connectome of subject 1, and the scores partition for this individual (based on the group)
%% We'll first use the ordering based on the group hierarchy
%% and then the ordering of the individual
figure
order_g = niak_hier2order(hier_g);
R = corr(tseries);
subplot(2,2,1)
niak_visu_matrix(abs(Rg(order_g,order_g)));
title('Group connectome (group ordering)')
subplot(2,2,2)
niak_visu_matrix(abs(R(order_g,order_g)));
title('individual connectome (group ordering)')
subplot(2,2,3)
niak_visu_part(part_g(order_g))
title('group partition')
subplot(2,2,4)
niak_visu_part(res.part_cores(order_g));
title('individual partition')
print('partition_scale10_group_vs_ind.png','-dpng')

%% Finally, let's estimate the stability of the individual DMN on sliding windows:
opt_scores.sampling.type = 'window';
opt_scores.sampling.opt.length = 30; % use a time window of the same length of the time series
res = niak_stability_scores_v2(tseries,part_g,opt_scores);
vol_stab = niak_part2vol(res.stab_maps(:,8),rois); % build a volumetric version of the partition
hf = figure; % do a montage of the partition
niak_montage(vol_stab)
print('montage_scale8_group.png','-dpng');
hdr.file_name = 'partition_scale8_group.nii.gz'; % save the partition in a nifti file
niak_write_vol(hdr,vol_part); 
