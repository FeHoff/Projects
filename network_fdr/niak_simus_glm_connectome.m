function [model,mask_true] = niak_simus_glm_connectome(opt)
% Generate connectomes for general linear model analysis
%
% [MODEL,MASK_TRUE] = NIAK_SIMU_GLM_CONNECTOME(OPT)
%
% OPT.TYPE (string, default 'star') the type of scenario. Available options :
%   'star' : a connected set of changes X1<->X2; X1<->X3; X1<->X4, etc.
%      OPT.K (integer, default 10): the number of connections with a difference.
% OPT.N (integer, default 100) the number of regions.
% OPT.THETA (scalar, default 1) the deviation from 0 in average connectivity 
%   for group 2 (the std of the inter-subject variance is 1).
% OPT.S (integer,20) the number of subjects per group.
%
% MODEL.Y (array SxL) with L=N(N+1)/2
% MASK_TRUE (boolean vector 1xL) MASK_TRUE(i) = 1 if the hypothesis i is non-null,
%   and it is 0 otherwise.
%
%__________________________________________________________________________
% COMMENTS : 
%
% Copyright (c) Pierre Bellec, Centre de recherche de l'institut de 
% Gériatrie de Montréal, Département d'informatique et de recherche 
% opérationnelle, Université de Montréal, 2011.
% Maintainer : pbellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : simulation, connectome

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

%% Defaults
if nargin<1
    opt = struct;
end
opt = psom_struct_defaults( opt , ...
         { 'type' , 'n' , 'theta' , 's' } , ... 
         { 'star' , 100 , 1       , 20  } , false);

%% Generate background noise               
mask_true = false(opt.n,opt.n);
L = opt.n*(opt.n+1)/2;
model.y = randn(2*opt.s,L);

%% Generate boolean mask of true non-null hypothesis
switch opt.type
    case 'star'
        opt = psom_struct_defaults(opt,{'k'},{10},false);
        if opt.k > opt.n
            error ( 'K should be smaller than N')
        end
        mask_true(2:opt.k,1) = true;
        mask_true(1,2:opt.k) = true;
        mask_true = niak_mat2lvec(mask_true);
    case 'bist'
        opt = psom_struct_defaults(opt,{'pi_low' , 'pi_high' , 'mpart' },{ 0.1 , 0.2 , NaN },false);
        indm = unique(opt.mpart(:));
        indm = indm(randperm(length(indm)));
        indm = indm(1:ceil(opt.pi_low*length(indm)));
        mask_true = false(size(opt.mpart));
        for num_m = indm'
            indmm = find(opt.mpart==num_m);
            indmm = indmm(1:ceil(opt.pi_high*length(indmm)));
            mask_true(indmm) = true;
        end     
    otherwise
        error('%s is an unknown simulation type');
end

%% Add effects
model.y(1:opt.s,mask_true) = model.y(1:opt.s,mask_true) + opt.theta;

%% Generate covariates
model.x = [ ones(2*opt.s,1) [ones(opt.s,1) ; zeros(opt.s,1)]];
model.c = [0 ; 1];