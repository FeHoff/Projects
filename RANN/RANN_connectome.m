% Template for the CONNECTOME pipeline
%
% To run this pipeline, the fMRI datasets first need to be preprocessed 
% using the NIAK fMRI preprocessing pipeline, and a set of functional 
% parcelations have to be generated using the BASC pipeline. 
%
% WARNING: This script will clear the workspace
%
% Copyright (c) Pierre Bellec, 
%   Research Centre of the Montreal Geriatric Institute
%   & Department of Computer Science and Operations Research
%   University of Montreal, Québec, Canada, 2013
% Maintainer : pierre.bellec@criugm.qc.ca
% modified by Perrine Ferré, 20151226

% See licensing information in the code.
% Keywords : medical imaging, fMRI, preprocessing, pipeline

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

clear 
path_data = '/home/perrine/scratch/RANN/preprocess_data_oct_2015_2';
path_niak = '/home/perrine/quarantaine/niak-boss-0.13.4/';
path_out  = '/home/perrine/scratch/RANN/RANN_connectome/';


%% Set the template
files_in.network = [path_niak 'template/basc_cambridge_sc100.mnc.gz'];


%% Grabbing the results from the NIAK fMRI preprocessing pipeline
opt_g.min_nb_vol = 100;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt_g.min_xcorr_func = 0.5; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of functional images in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.min_xcorr_anat = 0.5; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of the anatomical image in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
%opt_g.exclude_subject = {'subject1','subject2'}; % If for whatever reason some subjects have to be excluded that were not caught by the quality control metrics, it is possible to manually specify their IDs here.
opt_g.type_files = 'glm_connectome'; % Specify to the grabber to prepare the files for the glm_connectome pipeline
%opt_g.filter.session = {'session1'}; % Just grab session 1
%opt_g.filter.run = {'REST'}; % Just grab the "rest" run
%%%%%%%% test with rest but in a second step run it all together or each session separately?

% Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 
files_in.fmri = niak_grab_fmri_preprocess ('/home/perrine/scratch/RANN/preprocess_data_oct_2015_2',opt_g);

%% Set the seeds
files_in.seeds = [path_niak 'template/list_seeds_cambridge_100_full.csv'];

%% Options 
opt.folder_out = path_out; % Where to store the results
opt.connectome.type = 'Z'; % The type of connectome. See "help niak_brick_connectome" for more info. 
% 'S': covariance; 
%'R': correlation; 
%'Z': Fisher transform of the correlation; 
%'U': concentration; 
%'P': partial correlation.
opt.connectome.thresh.type = 'sparsity_pos'; % The type of treshold used to binarize the connectome. See "help niak_brick_connectome" for more info. 
% 'sparsity': keep a proportion of the largest connection (in absolute value); 
% 'sparsity_pos' keep a proportion of the largest connection (positive only)
% 'cut_off' a cut-off on connectivity (in absolute value)
% 'cut_off_pos' a cut-off on connectivity (only positive) 
opt.connectome.thresh.param = 0.2; % the parameter of the thresholding. The actual definition depends of THRESH.TYPE:
% 'sparsity' (scalar, default 0.2) percentage of connections
% 'sparsity_pos' (scalar, default 0.2) percentage of connections
% 'cut_off' (scalar, default 0.25) the cut-off
% 'cut_off_pos' (scalar, default 0.25) the cut-off       


%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%
opt.flag_test = false; % Put this flag to true to just generate the pipeline without running it. Otherwise the pipeline will start. 

opt.psom.max_queued = 300; % Uncomment and change this parameter to set the number of parallel threads used to run the pipeline, usualy one per subject 
[pipeline,opt] = niak_pipeline_connectome(files_in,opt);