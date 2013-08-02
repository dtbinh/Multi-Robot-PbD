%Main function

function calModel()
    clc;
    clear;
    delete('data/*.mat');
    path = 'data/';
    numDemo = 3;
    numDim = 17;    %8 joint angles (RSholderPitch, RShoulderRoll, RElbowYaw, RElbowRoll, RwristYaw, RHand, LHip, RHip)
                    %+ 6 end effector = 14
    
    read(path, numDemo, numDim);   
    [Priors, Mu, Sigma] = model();
    save('data/Priors.mat', 'Priors');
    save('data/Mu.mat', 'Mu');
    save('data/Sigma.mat', 'Sigma');

end