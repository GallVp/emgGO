%TRAINPSO Particle Swarm Optimization backpropagation.
%
%  Syntax
%  
%    [net,tr,Ac,El] = trainpso(net,Pd,Tl,Ai,Q,TS,VV,TV)
%    info = trainpso(code)
%
%  Description
%
%    TRAINPSO is a network training function that updates weight and
%    bias values according to particle swarm optimization.
%
%    TRAINPSO(NET,Pd,Tl,Ai,Q,TS,VV,TV) takes these inputs,
%      NET - Neural network.
%      Pd  - Delayed input vectors.
%      Tl  - Layer target vectors.
%      Ai  - Initial input delay conditions.
%      Q   - Batch size.
%      TS  - Time steps.
%      VV  - Empty matrix [] or structure of validation vectors.
%      TV  - Empty matrix [] or structure of test vectors.
%    and returns:
%      NET - Trained network.
%      TR  - Training record of various values over each epoch:
%            TR.epoch - Epoch number.
%            TR.perf  - Training performance.
%            TR.vperf - Validation performance.
%            TR.tperf - Test performance.
%      Ac  - Collective layer outputs for last epoch.
%      El  - Layer errors for last epoch.
%
%    Training occurs according to the TRAINPSO's training parameters
%    shown here with their default values:
%     trainParam.display  = 0;           iterations to update display (0 means never)
%     trainParam.maxit    = 2000;        maximum iterations
%     trainParam.popsz    = 25;          population size
%     trainParam.ac       = [2,2];       acceleration constants (for type = 0)
%     trainParam.inwt     = [0.9,0.4];   inertia weights (for type = 0)
%     trainParam.it_inwt  = floor(0.8*trainParam.maxit) iters to reach final inertia weight
%     trainParam.egd      = 1e-9;        minimum error gradient
%     trainParam.iter_egd = floor(0.2*trainParam.maxit) iters at errgrad value before exit
%     trainParam.eg       = 0;           error goal, NaN is unconstrained
%     trainParam.type     = 2;           chooses type of pso (common, clerc, etc)
%     trainParam.seedflag = 0;           flag to tell if we want to seed particles
%     trainParam.plotfcn  = 'goplotpso'; plotting function  
%     trainParam.seedvals = NaN;         Seed values
%
%    TRAINPSO(CODE) returns useful information for each CODE string:
%      'pnames'    - Names of training parameters.
%      'pdefaults' - Default training parameters.

% Structure of this code was taken from traingd.m by:
% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $ $Date: 2002/04/14 21:35:53 $
%
% All the PSO specific stuff is of course by Brian Birge
% Rev 1.0 - 8/31/05

function [net,tr,Ac,El,v5,v6,v7,v8] = ...
   trainpso(net,Pd,Tl,Ai,Q,TS,VV,TV,v9,v10,v11,v12)

  %global Tl Pd net Ai Q TS simfuncname
  
% FUNCTION INFO
% =============

if isstr(net)
  switch (net)
    case 'pnames',
      net = {...
             'display  = iterations to update display (0 means never)';...
             'maxit    = maximum iterations';...
             'popsz    = population size';...
             'ac       = acceleration constants (for type = 0)';...
             'inwt     = inertia weights (for type = 0)';...
             'it_inwt  = iterations to reach final inertia weight';...
             'egd      = minimum error gradient';...
             'iter_egd = # of iters at errgrad value before exit';...
             'eg       = error goal, NaN means unconstrained';...
             'type     = version of pso to use (0=common, 1,2=Trelea, 3=Clerc)';...
             'seedflag = 0 for no seed, 1 for seeded particles';...
             'plotfcn  = plot function to use if display ~= 0';...
             'seedvals = initial particle positions to use if seedflag~=0';...
             'minmax   = variable range for search [min,max], each row is a dimension';...
             'mvden    = maximum velocity divisor, default = 2';...
             'IWrange  = range to search for initial layer weights [min,max], default = [-100,100]';...
             'LWrange  = range to search for hidden/output layer weights [min,max], default = [-100,100]';...
             'BIrange  = range to search for hidden/output biases [min,max], default = [-8,8]';...
             'outlyrrange = range of output layer weights [min,max], defaults same as LWrange';...
            };

    case 'pdefaults',
      trainParam.display  = 25;    % iterations to update display (0 means never)
      trainParam.maxit    = 2000;  % maximum iterations
      trainParam.popsz    = 25;    % population size
      trainParam.ac       = [2,2]; % acceleration constants (for type = 0)
      trainParam.inwt     = [0.9,0.4]; % inertia weights (for type = 0)
      trainParam.it_inwt  = floor(0.8*trainParam.maxit); % iterations to reach final inertia weight
      trainParam.egd      = 1e-9;  % minimum error gradient
      trainParam.iter_egd = floor(0.2*trainParam.maxit); % # of iters at errgrad value before exit
      trainParam.eg       = 0;     % NaN is unconstrained optimization
      trainParam.type     = 2;     % chooses type of pso (common, clerc, etc)
      trainParam.seedflag = 0;     % flag to tell if we want to seed particles
      trainParam.plotfcn  = 'goplotpso4net';
      trainParam.seedvals = NaN; % only activated if seedflag == 1
      
      % this little section allows different search ranges based on whether
      % parameter is initial layer weight, hidden layer weight, or bias.
      % This has varying degrees of usefuleness depending on your activation function
      % choices and whether you normalize the i/o to the net
      trainParam.IWrange = [-100,100]; % Initial Layer Weight Range for search
      trainParam.LWrange = [-100,100]; % Hidden Layer Weight Range for search
      trainParam.BIrange = [-8,8]; % Bias Range for search
      trainParam.outlyrrange = trainParam.LWrange; % output layer weights, useful if you have a purelin act fcn for the output layer, you can then make this larger
      trainParam.mvden  = 2;
      % trainParam.keymap = ???? <--- this must be calculated in trainpso after
      %trainParam.minmax = ???? ; % default variable range, setup below using IWrange, LWrange, BIrange
      
      % initialization
      net = trainParam;
      
    otherwise,
      error('Unrecognized code.')
  end
  return
end

% this part needed to pass to goplotpso4net
P = Pd{1};
T = Tl{end};

% setup min/max values separately for bias, input weight, and layer weights
% this uses hacked code from getx.m to figure out which indices in the vector
% correspond to biases, input weights, and layer weights

% keymap variable is useful for quickly finding out what is a weight and what is
% a bias, used in goplotpso4net
% the minmax variable is needed by the PSO to determine search ranges for each
% particle component, this mess here just allows separate search ranges for
% bias, initial layer weight, and hidden layer weight, NOTICE!!! --> the 2
% variables keymap and minmax are not created during a call to newff, they are
% created only at first call to train, when using trainpso
   inputLearn     = net.hint.inputLearn;
   layerLearn     = net.hint.layerLearn;
   biasLearn      = net.hint.biasLearn;
   inputWeightInd = net.hint.inputWeightInd;
   layerWeightInd = net.hint.layerWeightInd;
   biasInd        = net.hint.biasInd;

   % setup range for weights & biases used in training
   % and create key telling us which indices are for input weights, layer
   % weights, or biases, when using x=getx(net);
   % keymap = [x,y], where x tells whether it is a weight or bias, and y is
   % the hidden/output layer associated with it
   % x=0 bias
   % x=1 initial layer weight
   % x=2 hidden/output layer weight
   % y = layer that x is on
   net.trainParam.minmax = zeros(net.hint.xLen,2);
   net.trainParam.keymap = zeros(net.hint.xLen,2);
   for i=1:net.numLayers
     for j=find(inputLearn(i,:))
       % range to search for input weights 
       net.trainParam.minmax(inputWeightInd{i,j},1:2) =...
          repmat(net.trainParam.IWrange,length(inputWeightInd{i,j}),1);
       
       net.trainParam.keymap(inputWeightInd{i,j},1:2) =...
          repmat([1,i],length(inputWeightInd{i,j}),1);
       
     end
     
     for j=find(layerLearn(i,:))
       % range to search for layer weights  
       net.trainParam.minmax(layerWeightInd{i,j},1:2) =...
          repmat(net.trainParam.LWrange,length(layerWeightInd{i,j}),1);
       
       net.trainParam.keymap(layerWeightInd{i,j},1:2) =...
          repmat([2,i],length(layerWeightInd{i,j}),1);
     end

     if biasLearn(i)
       % range to search for biases  
       net.trainParam.minmax(biasInd{i},1:2) =...
          repmat(net.trainParam.BIrange,length(biasInd{i}),1);
       
       net.trainParam.keymap(biasInd{i},1:2) =...
          repmat([0,i],length(biasInd{i}),1);
     end
   end
   for j=find(layerLearn(net.numLayers,:))
       net.trainParam.minmax(layerWeightInd{net.numLayers,j},1:2) =...
          repmat(net.trainParam.outlyrrange,length(layerWeightInd{net.numLayers,j}),1);
   end
%------------------------------------------------------------------------------
%------------------------------------------------------------------------------
%------------------------------------------------------------------------------
% CALCULATION
% ===========
%assignin('base','net',net);
% Generate functions
simfunc         = gensimm(net);
[x,simfuncname] = fileparts(simfunc);

% Constants
this = 'TRAINPSO';
doValidation = ~isempty(VV);
doTest = ~isempty(TV);

% Initialize
stop = '';
startTime = clock;
X = getx(net);

if (doValidation)
  VV.net = net;
  vperf = feval(simfuncname,net,VV.Pd,VV.Ai,VV.Tl,VV.Q,VV.TS);
  VV.perf = vperf;
  VV.numFail = 0;
end
tr = newtr(net.trainParam.maxit,'perf','vperf','tperf');

% extract network architecture and convert to format needed for PSO runs
dims=length(X);

% PSO Parameters
mvden    = net.trainParam.mvden; % max velocity divisor
varrange = [];
mv       = [];

minx        = net.trainParam.minmax(:,1);
maxx        = net.trainParam.minmax(:,2);

for i=1:dims
   if length(minx)<dims
     varrange = [varrange;minx(1) maxx(1)]; 
   else
     varrange = [varrange;minx(i) maxx(i)];
   end
   mv       = [mv;(varrange(i,2)-varrange(i,1))/mvden];
end
minmax   = 0; % sets pso to 'minimize'

shw         = net.trainParam.display;
epoch       = net.trainParam.maxit;
ps          = net.trainParam.popsz;
ac          = net.trainParam.ac;
Iwt         = net.trainParam.inwt;
wt_end      = net.trainParam.it_inwt;
errgrad     = net.trainParam.egd;
errgraditer = net.trainParam.iter_egd;
errgoal     = net.trainParam.eg;
modl        = net.trainParam.type;
PSOseedflag = net.trainParam.seedflag;

psoparams   = [shw epoch ps ac(1) ac(2) Iwt(1) Iwt(2) wt_end errgrad ...
               errgraditer errgoal modl PSOseedflag];

plotfcn     = net.trainParam.plotfcn;
PSOseedVal  = net.trainParam.seedvals;

% call PSO routine, returns weights and biases of new network
[pso_out, tr.epoch, tr.perf] = pso_Trelea_vectorized('pso_neteval', dims, mv,...
                                          varrange,...
                                          minmax, psoparams, plotfcn,...
                                          PSOseedVal);

%assignin('base','bestweights',pso_out(1:end-1));

% apply new weights and biases to network
net = setx(net,pso_out(1:end-1));
% this is just to get El and Ac to return to caller
[perf,El,Ac,N,Zl,Zi,Zb] = feval(simfuncname,net,Pd,Ai,Tl,Q,TS);

return