function [Mu, Sigma] = reproject(Mu2, Sigma2, A, nbStates)

%% Re-project the GMM components in the original data space.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Project the centers of the Gaussian distributions, using only the spatial 
%components 
Mu(1,:) = Mu2(1,:);
Mu(2:nbVar,:) = A*Mu2(2:end,:) + Data_mean(:,1:nbStates);
%Project the covariance matrices, using only the spatial components
for i=1:nbStates
  A_tmp = [1 zeros(1,nbVar2-1); zeros(nbVar-1,1) A];
  Sigma(:,:,i) = A_tmp * Sigma2(:,:,i) * A_tmp';
  %Add a tiny variance to avoid numerical instability
  Sigma(:,:,i) = Sigma(:,:,i) + 1E-10.*diag(ones(nbVar,1));
end