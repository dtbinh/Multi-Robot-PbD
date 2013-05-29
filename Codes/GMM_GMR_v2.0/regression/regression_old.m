function regression(path)
%% Definition of the number of components used in GMM.
nbStates = 14;

%% Load a dataset consisting of 3 demonstrations of a 2D signal.
%path = '../data/B/';
load( strcat(path,'raw_all.mat') ); %load 'Data'
Data = raw_all;
nbVar = size(Data,1);
nbTime = size(Data,2)/3;

%% Training of GMM by EM algorithm, initialized by k-means clustering.
[Priors, Mu, Sigma] = EM_init_kmeans(Data, nbStates);
[Priors, Mu, Sigma] = EM(Data, Priors, Mu, Sigma);

%% Use of GMR to retrieve a generalized version of the data and associated
%% constraints. A sequence of temporal values is used as input, and the 
%% expected distribution is retrieved. 
expData(1,:) = linspace(min(Data(1,:)), max(Data(1,:)), nbTime);
[expData(2:nbVar,:), expSigma] = GMR(Priors, Mu, Sigma,  expData(1,:), [1], [2:nbVar]);

%% Plot demonstration 3D trajectory of end-effector
% demonstration
% x=2;
% y=3;
% z=4;
% figure; 
% title_handle = title('Demonstraed 3D trajecotry in regression.m','FontWeight','bold');
% set(title_handle,'String','This is a revised title')
% plot3(Data(x, 1:nbTime), Data(y, 1:nbTime), Data(z, 1:nbTime), 'r');
% hold on;
% plot3(Data(x, 1+nbTime:2*nbTime), Data(y, 1+nbTime:2*nbTime), Data(z, 1+nbTime:2*nbTime), 'b');
% hold on;
% plot3(Data(x, 2*nbTime+1:end), Data(y, 2*nbTime+1:end), Data(z, 2*nbTime+1:end), 'g');
% grid on;
% xlabel('x','fontsize',16); ylabel('y' ,'fontsize',16); zlabel('z','fontsize',16);
% 
% % reproduced 
% plot3(expData(x,:), expData(y,:), expData(z,:));
% grid on;
% xlabel('x','fontsize',16); ylabel('y' ,'fontsize',16); zlabel('z','fontsize',16);

%% Plot demonstration 2D trajectory of end-effector
% figure;
% subplot(1,2,1);
% title_handle =title('Demonstraed 3D trajecotry in regression.m','FontWeight','bold');
% set(title_handle,'String','This is a revised title');
% plot(Data(1, 1:nbTime), Data(2, 1:nbTime), 'r'); hold on;
% plot(Data(1,1+nbTime:2*nbTime), Data(2, 1+nbTime:2*nbTime), 'b'); hold on;
% plot(Data(1,2*nbTime+1:end), Data(2, 2*nbTime+1:end), 'g'); hold on;
% 
% subplot(1,2,2);
% title_handle = title('Demonstraed 2D trajecotry in regression.m','FontWeight','bold');
% set(title_handle,'String','This is a revised title')
% plot(expData(1,:), expData(2,:));
expData

%% Save data
% result(9:11,:) = (expData(2:end,:));
% result = result';
% save(strcat(path,'reproduced', 'result'))
% fName = strcat(path, 'reproduced.txt');         %# A file name
% fid = fopen(fName,'w');            %# Open the file
% dlmwrite(fName,result,'-append',...  %# Print the matrix
%          'delimiter','\t',...
%          'precision', 6);

%%Re-project to original space
load([path,'vector.mat']);
E
load([path,'meanMatrix.mat']);
size(meanMatrix)
reproject= E' * expData' + meanMatrix'

