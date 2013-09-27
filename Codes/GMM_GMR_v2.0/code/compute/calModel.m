% Main computation function
function hand = calModel()
    clc;
    clear;
    
    path = '../data/';
    numDemo = 4;
    numDim = 12;    % 6 hand pos + 8 joint angles (RSholderPitch, RShoulderRoll, RElbowYaw, RElbowRoll, RwristYaw, RHand, LHip, RHip)

    %% Step 1: read raw data to .mat
    delete([path, '*.mat']);
    read2mat(path, numDemo, numDim);
    
    %% Step 2: assemble raw to raw_all to the same length
    length = 200;
    raw_all = assemble2one(path, numDemo, numDim, length);
    
    
    tmp_all = raw_all';
    [nbVar, nbData] = size(tmp_all);
    fprintf('size of all data: [%d, %d]\n',nbVar, nbData);
    joint = tmp_all(7:end, :);

    %% Step 3: compute number of PCA for joint
    threshold = 0.98;
    [nbPC, percent] = numPCA(joint, threshold);
    fprintf('percent %f%%\n', percent'*100);
    
    %% Step 4: DTW aligenment
    flagDTW = 1;
    if flagDTW == 1
        joint = DTW(joint, length);
    end
    
    %% Step 5: dimension extration by PCA
    [prinDim, unprinDim, joint2, A] = DR(joint, nbPC);
    prinDim
    unprinDim
    
    %% Step 6: compute # of GMM by BIC
    maxStates =  6;
    nbStates = BIC(joint2, maxStates);
    fprintf('nbStates %d\n', nbStates);

    %% Step 7: train GMMData_mean
    onetime = [1:length];
    timeDim = repmat(onetime, [1, numDemo]);
    Data = [timeDim; joint];
    Data2 = [timeDim; joint2];
    %fprintf('size of Data %d\t\t Data2 %d\n',size(Data), size(Data2));
    [Priors, Mu, Sigma] = GMMwithReproject(Data, Data2, nbStates, A);

    %% Step 8: save params
    save([path, 'Priors.mat'], 'Priors');
    save([path, 'Mu.mat'], 'Mu');
    save([path, 'Sigma.mat'], 'Sigma');

    pause;
    close all;

end        
