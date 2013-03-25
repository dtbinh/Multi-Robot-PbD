clc;
clear;

% select reference demo
numDemo = 3;
demo_ref = readRaw('../data/B/demo_1');
demo = demo_ref(:,1:13);
[Time, Dimension] = size(demo);
stdr = std(demo);
sr = demo./repmat(stdr,Time,1)

[pc,score,latent,tsquare] = princomp(sr);

result = cumsum(latent)./sum(latent);
%biplot(pc(:,1:2),'Scores',score(:,1:2),'VarLabels',...
%		{'X1' 'X2' 'X3' 'X4' 'X5' 'X6' 'X7' 'X8' 'X9' 'X10' 'X11' 'X12' 'X13' 'X14' 'X15' 'X16'})