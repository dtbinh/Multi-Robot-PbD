%Main function
function calModel()
    clc;
    clear;
    
    path = 'data/';
    numDemo = 4;
    numDim = 14;    % 6 hand pos + 8 joint angles (RSholderPitch, RShoulderRoll, RElbowYaw, RElbowRoll, RwristYaw, RHand, LHip, RHip)

    % read raw data to .mat
 %   delete('data/*.mat');
 %   read2mat(path, numDemo, numDim);
    
    % assemble raw to one file raw_all, w/o DTW
    flagDTW = 0;
    length = 200;
    raw_all = assemble2one(path, numDemo, numDim, length, flagDTW);
    
    % queried by time
    tmp = raw_all';
    onetime = [1:length];
    timeDim = repmat(onetime, [1, numDemo]);
    Data =[timeDim; tmp];
    
    [nbVar, nbData] = size(Data);
    fprintf('size of Data: [%d, %d]\n',nbVar, nbData);

    % Training model with PCA and BIC
    maxStates = 6;
    threshold = 0.95;

    %queried by time
    flagDTW = 1;
    [Priors, Mu, Sigma, evalIndex] = trainModelwithPCA([Data(1,:); Data(8:end,:)], threshold, maxStates, flagDTW);
    
    %save params
    save('data/Priors.mat', 'Priors');
    save('data/Mu.mat', 'Mu');
    save('data/Sigma.mat', 'Sigma');

    pause;
    close all;

end        
