%Main function

function main()
    clc;
    clear;
    
    path = '../data/wiping/';
    numDemo = 3;
    numDim = 14;    %8 joint angles (RSholderPitch, RShoulderRoll, RElbowYaw, RElbowRoll, RwristYaw, RHand, LHip, RHip)
                    %+ 6 end effector = 14
    for     i = 1:numDemo
        readRaw(path, i);
        load(['raw_', num2str(i)]);
        eval(['x=raw_', num2str(i), ';']);
        if i == 1
            raw_all = x;
            ref = x;
        else
            new = resizem(x, [size(ref,1), numDim]);
            raw_all = [raw_all; new];
        end
    end
    save('raw_all.mat', 'raw_all');
    
    %read the last demo as query
    readRaw(path, numDemo+1);

    
%    nbPC = numPCA(3);
%    alignment(numDemo);
   
%    regression(numDemo);
end