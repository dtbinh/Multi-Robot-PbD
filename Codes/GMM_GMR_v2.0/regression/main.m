%Main function

function main()
    clc;
    clear;
    
    path = '../data/picking/';
    numDemo = 3;
    numDim = 17;    %8 joint angles (RSholderPitch, RShoulderRoll, RElbowYaw, RElbowRoll, RwristYaw, RHand, LHip, RHip)
                    %+ 6 end effector = 14
    
    % read(path, numDemo, numDim);  
    [Priors, Mu, Sigma] = demo2();
    dlmwrite([path,'Priors.txt'], Priors, 'delimiter', '\t');
    dlmwrite([path, 'Mu.txt'], Mu, 'delimiter', '\t');
    for i = 1:size(Sigma, 3)
        dlmwrite([path, 'Sigma.txt'], Sigma(:,:,1), '-append');
    end
    
%     load('raw_1.mat');
%     tmp = raw_1';
%     queryData =[tmp(1:3, :)];
%     %queryData = [0.2989; -0.0681; 0.2764];
%     [y, y_sigma] = GMR(Priors, Mu, Sigma, queryData, [1:3], [4:17]);
%     expData = (y(1:8, :))';
%     save('expData.mat', 'expData');
end