%Main function

function main()
    clc;
    clear;
    
    path = '../data/wiping/';
    
    numDemo = 4;
    numDim = 14;  %number of dimensions: 8 joint angles (RSholderPitch, RShoulderRoll, RElbowYaw, RElbowRoll, RwristYaw, RHand, LHip, RHip)
    %+ 6 end effector = 14

    readRaw(path, numDemo);
%    nbPC = numPCA(3);
%    alignment(numDemo);
   
%    regression(numDemo);
end