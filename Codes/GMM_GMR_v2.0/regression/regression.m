function regression(Priors, Mu, Sigma, queryData)

queryData = tmp(15:17, 1:1)
expData(1:3,:) = queryData;
[expData(4:17,:), expSigma] = GMR(Priors, Mu, Sigma,  expData(1:3,:), [1:3], [4:17]);
save('expData.mat', 'expData');