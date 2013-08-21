function [Data2, A] = PCA(Data, threshold)

[nbVar,nbData] = size(Data);

nbPC = numPCA(Data, threshold);
Data_mean = repmat(mean(Data,2), 1, nbData);
centeredData = Data - Data_mean;
%Extract the eigencomponents of the covariance matrix 
[E,v] = eig(cov(centeredData'));
E = fliplr(E);
%Compute the transformation matrix by keeping the first nbPC eigenvectors
A = E(:,1:nbPC);
%Project the data in the latent space
Data2(1:nbPC, :) = A' * centeredData;