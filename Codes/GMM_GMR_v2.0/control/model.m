function [Priors, Mu, Sigma] = model(Data, nbStates, numDemo)
%
% Demo of the spatial Gaussian Mixture Regression (GMR) using query points 
% of arbitrary dimensions. 
% This source code is the implementation of the algorithms described in 
% Section 2.4, p.38 of the book "Robot Programming by Demonstration: A 
% Probabilistic Approach". 
%
% This program loads a 4D dataset, trains a 
% Gaussian Mixture Model (GMM), and uses query points of 2 dimensions to 
% retrieve a generalized version of the data for the remaining 2 dimensions, 
% with associated constraints, through Gaussian Mixture Regression (GMR).
% Each datapoint has 4 dimensions, consisting of 2x2 spatial values 
% (e.g. drawing on a 2D Cartesian plane simultaneously with right and left 
% hand). A new sequence of 2D spatial values (i.e. data for left hand) is 
% loaded and used as query points to retrieve a sequence of expected 
% spatial distributiuon for the remaining dimensions (i.e. data for right 
% hand), through Gaussian Mixture Regression (GMR).
%

%% Load a dataset consisting of 3 demonstrations of a 2D signal.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load('data/data2_a.mat'); %load 'Data'
[Dim, numPoints] = size(Data);
nbVar = size(Data,1);

%% Training of GMM by EM algorithm, initialized by k-means clustering.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Priors, Mu, Sigma] = EM_init_kmeans(Data, nbStates);
[Priors, Mu, Sigma] = EM(Data, Priors, Mu, Sigma);

%% Use of GMR to retrieve a generalized version of the data and associated
%% constraints. A sequence of temporal values is used as input, and the 
%% expected distribution is retrieved. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% expData(1:2,:) = queryData;
% [expData(3:4,:), expSigma] = GMR(Priors, Mu, Sigma,  expData(1:2,:), [1:2], [3:4]);
%     expData(1:3,:) = queryData;
%     [expData(4:17,:), expSigma] = GMR(Priors, Mu, Sigma,  expData(1:3,:), [1:3], [4:17]);
%     save('expData.mat', 'expData');
%% Plot of the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure('position',[10,10,1000,800],'name','GMM-GMR-demo2'); 
% subplot(3,1,1); hold on;
% plot(Data(1,:), Data(2,:), 'x', 'markerSize', 4, 'color', [.8 0 0]);
% plot(Data(3,:), Data(4,:), 'x', 'markerSize', 4, 'color', [0 .8 0]);
% axis([min([Data(1,:),Data(3,:)])-0.02 max([Data(1,:),Data(3,:)])+0.02 ...
%   min([Data(2,:),Data(4,:)])-0.01 max([Data(2,:),Data(4,:)])+0.01]);
% xlabel('x_1,x_3','fontsize',16); ylabel('x_2,x_4','fontsize',16);
% 
% %% Plot of the GMM encoding results
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  subplot(3,1,2); hold on;
% plotGMM(Mu([1,2],:), Sigma([1,2],[1,2],:), [.8 0 0], 1);
% plotGMM(Mu([3,4],:), Sigma([3,4],[3,4],:), [0 .8 0], 1);
% axis([min([Data(1,:),Data(3,:)])-0.02 max([Data(1,:),Data(3,:)])+0.02 ...
%   min([Data(2,:),Data(4,:)])-0.01 max([Data(2,:),Data(4,:)])+0.01]);
% xlabel('x_1,x_3','fontsize',16); ylabel('x_2,x_4','fontsize',16);

%Chi
%  Mu
% subplot(3,1,2);


%plotGMM(Mu([3,4],:), Sigma([3,4],[3,4],:), [0 .8 0], 1);
% axis([min(Data(input_x,:))-0.2, max(Data(input_x,:))+0.2...
%  min(Data(input_y,:))-0.01 max(Data(input_y,:))+0.1]);


%% Plot of the GMR regression results
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subplot(3,1,3); hold on;
% plotGMM(expData([3,4],:), expSigma([1,2],[1,2],:), [0 0 .8], 2);
% plot(expData(1,:), expData(2,:), '-', 'lineWidth', 3, 'color', [0 0 .8]);
% axis([min([Data(1,:),Data(3,:)])-0.02 max([Data(1,:),Data(3,:)])+0.02 ...
%   min([Data(2,:),Data(4,:)])-0.01 max([Data(2,:),Data(4,:)])+0.01]);
% xlabel('x_1,x_3','fontsize',16); ylabel('x_2,x_4','fontsize',16);
% 
% pause;
% close all;
