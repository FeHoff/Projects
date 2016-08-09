function [files_in,files_out,opt] = adsf_brick_subtyping(files_in,files_out,opt)
% Build subtypes
% 
% SYNTAX:
% [FILES_IN,FILES_OUT,OPT] = ADSF_BRICK_SUBTYPING(FILES_IN,FILES_OUT,OPT)
% _________________________________________________________________________
% 
% INPUTS:
% 
% FILES_IN 
%   (structure) with the following fields:
%
%   DATA 
%       (string) path to a .mat file containing a variable STACK, which is 
%       an array (#subjects x #voxels OR vertices OR regions), see also
%       niak_brick_network_stack
%
%   MASK
%       (2D array) file name of a binary mask of the voxels that 
%       are included in the time*space array
% 
% FILES_OUT 
%   (structure) with the following fields:
%
%   SIM_FIG
%       (string, default 'similarity_matrix.png') path to the .pdf
%       visualization of the similarity matrix. 
%
%   DEN_FIG
%       (string, default 'dendrogram.png') path to the .pdf
%       visualization of the dendrogram
%
%   SUBTYPE
%       (string, default 'subtype.mat') path to subject by subtype by voxel
%       array .mat file
%
%   PROVENANCE
%       (string, default 'provenance.mat') path to ...
% 
% OPT 
%   (structure) with the following fields:
%
%   FOLDER_OUT
%       (string, default '') if not empty, this specifies the path where
%       outputs are generated
%
%   NB_SUBTYPE
%       (integer) the number of desired subtypes
%
%   SUB_MAP_TYPE
%       (string, default 'mean') how the subtypes are represented in the
%       volumes (options: 'mean' or 'median')
%
%   RAND_SEED
%       (scalar, default []) The specified value is used to seed the random
%       number generator with PSOM_SET_RAND_SEED. If left empty, no action
%       is taken.
%
%   FLAG_PROV
%       (boolean, default false) if the flag is true, the provenance and
%       brick options will be saved in the specified path in
%       FILES_OUT.PROVENANCE and not OPT.FOLDER_OUT
%
%   FLAG_VERBOSE
%       (boolean, default true) turn on/off the verbose.
%
%   FLAG_TEST
%       (boolean, default false) if the flag is true, the brick does not do 
%       anything but updating the values of FILES_IN, FILES_OUT and OPT.
% _________________________________________________________________________
% OUTPUTS:
% 
% FILES_OUT
%       Directory containing the following: 
%
%   SUBTYPES.MAT
%       (structure) with the following fields:
%
%       HIER
%           (2D array) defines the hierarchy. See also
%           NIAK_HIERARCHICAL_CLUSTERING
%
%       PART
%           (vector) PART(I) = J if the object I is in the class J.
%           See also: niak_threshold_hierarchy
%
%       SIM_MATRIX
%           (2D array) a #subject x #subject correlation matrix
%
%       SUB
%           (structure) contains subfield for different maps (e.g.
%           mean/median, ttest, effect) for each subtype
%
%       SUBJ_ORDER
%           (vector) order of objects based on HIER. See also:
%           NIAK_HIER2ORDER
%
%   PROVENANCE.MAT
%       (structure) with the following fields:
%
%       PROVENANCE
%           (structure) contains information on subjects, model, and
%           volume used in the analysis
%
%       OPT
%           (structure) a copy of the options specified in OPT
%
% The structures FILES_IN, FILES_OUT and OPT are updated with default
% valued. If OPT.FLAG_TEST == 0, the specified outputs are written.


%% Initialization and syntax checks

% Syntax
if ~exist('files_in','var')||~exist('files_out','var')||~exist('opt','var')
    error('niak:brick','syntax: [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_SUBTYPING(FILES_IN,FILES_OUT,OPT).\n Type ''help niak_brick_subtyping'' for more info.')
end

% Input
files_in = psom_struct_defaults(files_in,...
           { 'data' , 'mask' },...
           { NaN    , NaN    });
[path_m,name_m,ext_m] = niak_fileparts(files_in.mask);

% Options
opt = psom_struct_defaults(opt,...
      { 'folder_out' , 'nb_subtype', 'sub_map_type', 'rand_seed', 'flag_prov' , 'flag_verbose' , 'flag_test' },...
      { ''           , NaN         , 'mean'        , []         , false       , true           , false       });

% Output
if ~isempty(opt.folder_out)
    path_out = niak_full_path(opt.folder_out);
    files_out = psom_struct_defaults(files_out,...
                { 'sim_fig'                          , 'den_fig'                   , 'subtype'                , 'provenance'                },...
                { [path_out 'similarity_matrix.pdf'] , [path_out 'dendrogram.pdf'] , [path_out 'subtype.mat'] , [path_out 'provenance.mat'] });
else
    files_out = psom_struct_defaults(files_out,...
                { 'sim_fig'         , 'den_fig'         , 'subtype'         , 'provenance'      },...
                { 'gb_niak_omitted' , 'gb_niak_omitted' , 'gb_niak_omitted' , 'gb_niak_omitted' });
end

if opt.flag_prov && isempty(files_out.provenance)
    warning('Provenance and options will not save when OPT.FLAG_PROV is true but FILES_OUT.PROVENANCE is empty')
end
  
% If the test flag is true, stop here !
if opt.flag_test == 1
    return
end

%% Seed the random generator
if ~isempty(opt.rand_seed)
    psom_set_rand_seed(opt.rand_seed);
end

%% Load the data
data = load(files_in.data);
provenance = data.provenance; % loading provenance from the data file
data = data.stack; % get the stack data

%% Build the similarity matrix
sim_matrix = niak_build_correlation(data');

%% Compute the hierarchy
% Cluster subjects
hier = niak_hierarchical_clustering(sim_matrix);
% Reorder subjects based on clustering
subj_order = niak_hier2order(hier);
% Generate re-ordered matrix
rm = sim_matrix(subj_order,subj_order);

%% Saving the clustering and matrix
if ~strcmp(files_out.sim_fig, 'gb_niak_omitted')
    % Save the similarity matrix as pdf
    opt_pdf.limits = [-0.8 0.8];
    opt_pdf.color_map = 'hot_cold';
    fh1 = figure('Visible', 'off');
    niak_visu_matrix(rm,opt_pdf);
    print(fh1, files_out.sim_fig,'-dpdf','-r300');
end

if ~strcmp(files_out.den_fig, 'gb_niak_omitted')
    % Generate and save dendrogram as pdf
    fh2 = figure('Visible', 'off');
    niak_visu_dendrogram(hier);
    print(fh2, files_out.den_fig,'-dpdf','-r300');
end

%% Read the mask
mask = load(files_in.mask);
mask = mask.mask;
mask = logical(mask);
% Get the number of vertices
n_vox = length(mask);

%% Build the clusters by thresholding the hiearchy by the number of subtypes
part = niak_threshold_hierarchy(hier,struct('thresh',opt.nb_subtype));

%% Build subtype maps

% Generating and writing the mean or the median subtype maps 
sub.map = zeros(opt.nb_subtype, n_vox);
for ss = 1:opt.nb_subtype
    if strcmp(opt.sub_map_type, 'mean')
        % Construct the subtype map as the mean map of the subgroup
        sub.map(ss,:) = mean(data(part==ss,:),1);
    elseif strcmp(opt.sub_map_type, 'median')
        % Construct the subtype map as the median map of the subgroup
        sub.map(ss,:) = median(data(part==ss,:),1);
    end
end

%% Generating and writing t-test and effect maps of the difference between subtype

sub.ttest = zeros(opt.nb_subtype, n_vox);
sub.mean_eff = zeros(opt.nb_subtype, n_vox);
for ss = 1:opt.nb_subtype
    [sub.ttest(ss,:), ~, sub.mean_eff(ss,:), ~, ~] = niak_ttest(data(part==ss,:), data(part~=ss,:),true);
end
% mask out NaN values with zeros
sub.ttest(isnan(sub.ttest)) = 0;
sub.mean_eff(isnan(sub.mean_eff)) = 0;

%% Generate and write grand mean map
sub.gd_mean = mean(data,1);
    
% Generate and write the grand std map
sub.gd_std = std(data,1);

%% Saving subtyping results and statistics
if ~strcmp(files_out.subtype, 'gb_niak_omitted')
    save(files_out.subtype,'subj_order','sim_matrix','sub','hier','part')
end

% Save provenance and options in separate .mat file
if ~isempty(files_out.provenance) && ~strcmp(files_out.provenance, 'gb_niak_omitted')
    if opt.flag_prov
        prov_file = files_out.provenance;
    else
        prov_file = [path_out 'provenance.mat'];
    end
    save(prov_file,'provenance','opt');
end

end

function path_array = make_paths(out_path, template, scales)
    % Get the number of networks
    n_networks = length(scales);
    path_array = cell(n_networks, 1);
    for sc_id = 1:n_networks
        sc = scales(sc_id);
        path = fullfile(out_path, sprintf(template, sc));
        path_array{sc_id, 1} = path;
    end
return
end







