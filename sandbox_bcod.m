%%
cd('/home/manishm/BiconditionalOdor/M142/M142-2020-09-30-CDOD1/');
cfg = [];
cfg.uint = '64';

[evt, S] = LoadSession(cfg);

cfg = [];


FR = [];
FR.cfg.dt = .001;
FR.cfg.trlInt = [-1 5];
FR.cfg.npTrl = [-1 1];
FR.cfg.minSpk = 200;
FR.cfg.nShuf = 20;
FR.cfg.trlLen = 1;
FR.cfg.delayT = 2;
FR.cfg.zscore = 2.58;
FR.cfg.use_cells = 0;
FR.cfg.smooth = 'none';
FR.cfg.nWins = length(FR.cfg.trlInt(1):FR.cfg.trlLen:FR.cfg.trlInt(2)-FR.cfg.trlLen);
FR.cfg.PETHdt = .01;

task = getEvents(cfg,evt);
%%

cfg = [];
cfg.dt = 0.001; %0.05; %.05 for glm, .001 for PCA to get better smoothing
cfg.smooth = 0;
cfg.goodTrials = 1;
cfg.gausswin_size = .1; % in seconds
cfg.gausswin_sd = 0.02; % in seconds
Q = binEvents(cfg,S,task);

%% get PETHs for plotting
cfg = [];
cfg.dt = 0.001;
cfg.trlInt = FR.cfg.trlInt;
cfg.trlLen = FR.cfg.trlLen;
cfg.delayT = FR.cfg.delayT;
cfg.ExpKeys = evt.cfg.ExpKeys;
out = [];
out = getPETHv2(cfg,FR,Q);


%% Transform data from ugly to less so
test = [];
for iC = 1:length(out.raw)
    test = [test sum(cellfun(@(x) size(x{1},1), out.raw{iC}))];
end
select = find(test == 335);
final = [];
for iC = 1:length(select)
    this_cell = out.raw{select(iC)};
    this_data = [];
    ctx = [];
    for iT = 1:length(this_cell);
        this_data = [this_data; cell2mat(this_cell{iT})];
        ctx = [ctx; iT*ones(size(cell2mat(this_cell{iT}),1),1)];
    end
    final(iC,:,:) = [this_data];
end
%%
dt = cfg.dt;
spikes = final;
timeMs = 1000*(dt:dt:6);
conditionId = ctx;
true_rates = [];
subject = 'M142';
datnum = datenum(2020,9,30);
nChannels = size(final,1);
nTrials = size(final,2);
spikes = permute(spikes,[2, 1,3]);
%%
