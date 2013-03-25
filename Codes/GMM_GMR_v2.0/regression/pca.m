clc;
clear;
path = '../data/B/';
%% Projection of the Data_align in a latent space using PCA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Re-center the Data_align
load(strcat(path,'aligned.mat'));
[pc,score,latent,tsquare] = princomp(Data_align(2:end, :));
percent = cumsum(latent)./sum(latent);
[nbVar,nbData_align] = size(Data_align);
for i=1:size(percent)
    if percent(i) > 0.98;
    nbPC=i
    break;
    end
end

Data_align_mean = repmat(mean(Data_align(2:end,:),2), 1, nbData_align);
centeredData_align = Data_align(2:end,:) - Data_align_mean;
%Extract the eigencomponents of the covariance matrix 
[E,v] = eig(cov(centeredData_align'));
E = fliplr(E);
%Compute the transformation matrix by keeping the first nbPC eigenvectors
A = E(:,1:nbPC);
%Project the Data_align in the latent space
nbVar2 = nbPC+1;
Data(1,:) = Data_align(1,:);
Data(2:nbVar2,:) = A' * centeredData_align;

%save low dimention projection Data_align
save(strcat(path,'reduceDim.mat'), 'Data');