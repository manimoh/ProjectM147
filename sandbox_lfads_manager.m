% Identify the datasets you'll be using
% Here we'll add one at ~/lorenz_example/datasets/dataset001.mat
dc = BCOD.DatasetCollection('/home/manishm/BiconditionalOdor');
dc.name = 'BCOD';
ds = BCOD.Dataset(dc, 'bcod_test.mat'); % adds this dataset to the collection
dc.loadInfo; % loads dataset metadata
%%
% Run a single model for each dataset, and one stitched run with all datasets
runRoot = '/home/manishm/code/LFADS/ProjectM147/runs';
rc = BCOD.RunCollection(runRoot, 'example', dc);

% run files will live at ~/lorenz_example/runs/example/

% Setup hyperparameters, 4 sets with number of factors swept through 2,4,6,8
par = BCOD.RunParams;
par.spikeBinMs = 2; % rebin the data at 2 ms
par.c_co_dim = 0; % no controller outputs --> no inputs to generator
par.c_batch_size = 64; % must be < 1/5 of the min trial count
par.c_gen_dim = 12; % number of units in generator RNN
par.c_ic_enc_dim = 612; % number of units in encoder RNN
par.c_learning_rate_stop = 1e-3; % we can stop really early for the demo
par.c_debug_verbose = true;
par.c_tf_debug_cli=true;
par.c_tf_debug_tensorboard=true;
%par.c_tf_debug_tensorboard_hostport=localhost:6064;
%par.c_tf_debug_dump_root
par.c_debug_verbose=true;
par.c_debug_reduce_timesteps_to=[];
par.c_debug_print_each_step=true;
%parSet = par.generateSweep('c_factors_dim', [2 4 6 8]);
rc.addParams(parSet);

% Setup which datasets are included in each run, here just the one
runName = dc.datasets(1).getSingleRunName(); % == 'single_dataset001'
rc.addRunSpec(BCOD.RunSpec(runName, dc, 1));

% Generate files needed for LFADS input on disk
rc.prepareForLFADS();
%%
% Write a python script that will train all of the LFADS runs using a
% load-balancer against the available CPUs and GPUs
rc.writeShellScriptRunQueue('display', 0, 'virtualenv', 'tensorflow');