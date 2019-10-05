% demoPSOnet.m
% script to show a quick, uncomplicated demo of using trainpso for training
% a neural net
%
% tries to build a feedforward neural net to approximate a noisy increaing 
% sin function
% only uses 1/2 the data for training, to show generalization with all data at
% end

% Brian Birge
% Rev 1.0
% 3/14/06

clear all
close all
help demoPSOnet

% setup data
P1 = [0:.01:1]; % input, each neural input is a row vector
T1 = sin(P1*8)+rand(size(P1))*.5 + P1;  % noisy sin, output, each neural output is a row vector

%loadnmerge
%T1 = I_Rnorm';
%P1 = [JD_mid_exposure';ones(1,tlen)*28636];

P = P1(:,1:2:end-1); % only use half the data for training
T = T1(:,1:2:end-1); % because we want to test net's response to unknown inputs

Sn = [3,5,length(T1(:,1))];  % [# of hidden layer neurons, # output layer neurons]
TF = {'tansig','tansig','purelin'}; % act funct for each hidden layer and output layer
PF = 'msereg'; % performance function, can change to mse or sse etc

% initialize feedforward network
net = newff([min(P,[],2),max(P,[],2)],... % input parameter ranges
            Sn,...                        % # of hidden, output layers
            TF,...                        % act fcn for each hidden/output layer
            'trainpso',...                % training method
            'learngdm',...                % learning method
            PF);                          % performance fcn

net.trainParam.maxit = 2000; % play around with this (2000 is trainpso default)

% train network, using partial data
[net,tr] = train(net,P,T);

% simulate network using all data
Y = sim(net,P1);

% display all data
figure
plot(P1,T1,'b','linewidth',2) % show original data
hold on
plot(P1,Y,'r') % show net-trained data
xlabel('in')
ylabel('out')
title('All Data, Blue = known, Red = net')