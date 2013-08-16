%Main function

function calModel()
    clc;
    clear;
    
    path = 'data/';
    numDemo = 3;
    numDim = 14;    % 3 ball position + 3 hand position + 8 joint angles (RSholderPitch, RShoulderRoll, RElbowYaw, RElbowRoll, RwristYaw, RHand, LHip, RHip)
  
 
 %   delete('data/*.mat');
 %   flagDTW = 0;
 %   readAll(path, numDemo, numDim, flagDTW);
 
 
    load('data/raw_all.mat');
    numStates = 3;
    tmp = raw_all';
    
%     tmp(4, :) = tmp(4, :) - tmp(1, :);
%     tmp(5, :) = tmp(5, :) - tmp(2, :);
%     tmp(6, :) = tmp(6, :) - tmp(3, :);

    Data =  tmp;
    disp('size of Data:  ');
    [Dim, numPoints] = size(Data)
    
    [Priors, Mu, Sigma] = model(Data, numStates, numDemo);
    
    
    figure;
    hold on;

    input_x = 4;
    input_y = 5;
    plotDim = [input_x, input_y];
    %plotDim = [input_x];
    Mu(plotDim, :)
    plotGMM(Mu([plotDim],:), Sigma([plotDim],[plotDim],:), [.8 0 0], 1);

    plot(Data(input_x,1:numPoints/numDemo), Data(input_y, 1:numPoints/numDemo), 'r');
    plot(Data(input_x,numPoints/numDemo + 1: 2 * numPoints/numDemo), Data(input_y, numPoints/numDemo + 1: 2*numPoints/numDemo), 'b');
    plot(Data(input_x,2 * numPoints/numDemo + 1:numPoints), Data(input_y, 2 * numPoints/numDemo + 1:numPoints), 'g');

   
    plot(Data(1,numPoints/numDemo), Data(2, numPoints/numDemo), 'ro'); hold on;
    plot(Data(1,numPoints/numDemo * 2), Data(2, numPoints/numDemo * 2), 'bo'); hold on;
    plot(Data(1,numPoints/numDemo * 3), Data(2, numPoints/numDemo * 3), 'go'); hold on;
    xlabel('x','fontsize',16); ylabel('y','fontsize',16);
    
    
    save('data/Priors.mat', 'Priors');
    save('data/Mu.mat', 'Mu');
    save('data/Sigma.mat', 'Sigma');
end         