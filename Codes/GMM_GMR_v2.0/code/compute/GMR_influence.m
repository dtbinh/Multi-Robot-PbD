function beta = GMR_influence(x, in, out)

load('../data/Sigma.mat');
load('../data/Mu.mat');

nbStates = size(Sigma,3);

for i=1:nbStates
  Pxi(:,i) = gaussPDF(x, Mu(in,i), Sigma(in,in,i));
end
beta = (Pxi./repmat(sum(Pxi,2)+realmin,1,nbStates))';

