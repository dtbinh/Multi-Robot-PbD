% Main computation function
function calModel()
    clc;
    clear;
    
    path = '../data/';
    numDemo = 4;
    numDim = 12;    % 6 hand pos + 8 dim angles (RSholderPitch, RShoulderRoll, RElbowYaw, RElbowRoll, RwristYaw, RHand, LHip, RHip)

    %% Step 1: read raw data to .mat
%     delete([path, '*.mat']);
%     read2mat(path, numDemo, numDim);
    
    %% Step 2: assemble raw to raw_all to the same length
    length = 200;
    raw_all = assemble2one(path, numDemo, numDim, length);
    
    tmp_all = raw_all';
    [nbVar, nbData] = size(tmp_all);
    fprintf('size of all data: [%d, %d]\n',nbVar, nbData);
    hand = tmp_all(1:6, :);
    joint = tmp_all(7:end, :);
    dim = joint;

    %% Step 3: compute number of PCA for dim
    % normalization
    mu = mean(dim');
    dim = dim - repmat(mu', 1, 800);
    delta = std(dim');
    delta2 = sqrt(sum([dim.*dim]')/800)
    delta - delta2
    dim = dim ./ repmat(delta2', 1, 800);
    
%      dimTest = dim';
%      tt = bsxfun(@minus, dimTest, mean(dimTest));
%      tt = bsxfun(@rdivide, tt, std(dimTest));   
%      dim = tt';
%     
    threshold = 0.90;
    [nbPC, percent] = numPCA(dim, threshold);
    fprintf('percent %f%%\n', percent'*100);
    
    %% Step 4: DTW aligenment
    flagDTW = 1;
    if flagDTW == 1
        dim = DTW(dim, length);
    end
    
    %% Step 5: dimension extration by PCA
    [prinDim, unprinDim, dim2, A, dim3, rest_A] = DR(dim, nbPC);
    prinDim
    unprinDim
    A
    rest_A
    
    %% Step 6: compute # of GMM by BIC
    maxStates =  6;
    nbStates = BIC(dim2, maxStates);
    fprintf('nbStates %d\n', nbStates);

    %% Step 7: train GMMData_mean
    onetime = [1:length];
    timeDim = repmat(onetime, [1, numDemo]);
    Data = [timeDim; dim];
    Data2 = [timeDim; dim2];
    %fprintf('size of Data %d\t\t Data2 %d\n',size(Data), size(Data2));
    [Priors, Mu, Sigma] = GMMwithReproject(Data, Data2, nbStates, A);

    %% Step 8: save params
     save([path, 'Priors.mat'], 'Priors');
     save([path, 'Mu.mat'], 'Mu');
     save([path, 'Sigma.mat'], 'Sigma');
 
     pause;
     close all;

end        
