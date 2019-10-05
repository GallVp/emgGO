% pso_neteval.m
% function to evaluate a neural nets performance as called from
% the PSO function: pso_Trelea_vectorized.m and trainpso.m
%
%  usage: cost = pso_neteval(x)
%   where x is an MxN array of weights & biases
%       M is particle index
%       N is weight & bias index

% Brian Birge
% Rev 2.0
% 3/8/06

function cost = pso_neteval(x)
  for i=1:length(x(:,1)) % # of particles passed, because of simfuncname we can't vectorize
    net = evalin('caller','net');

    Pd = evalin('caller','Pd');
    Tl = evalin('caller','Tl');
    Ai = evalin('caller','Ai');
    Q  = evalin('caller','Q');
    TS = evalin('caller','TS');
    
    X   = x(i,:)';    
    net = setx(net,X); % setx is mega-slow

    [perf,El,Ac,N,Zb,Zi,Zl] = calcperf(net,X,Pd,Tl,Ai,Q,TS);

    cost(i,1) = perf;
  end
  
return