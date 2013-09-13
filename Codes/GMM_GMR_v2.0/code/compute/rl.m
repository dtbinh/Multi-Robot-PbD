function [solution, Q] = rl()
    clc;
    clear;
    load('../data/Mu.mat');
    length = 200;
    Jacobian = forwardKinect();
    hand_std = zeros(length, 6);
    for time = 1 : length
        joint = GMRwithParam(time, 1, [2:9], Mu);
        
        hand_std(time, :) = testForwardKinect([joint]', Jacobian);

    end
    
    goal = mean(hand_std(80:100, 3)) - 0.03;
    
    
    %[bestMu, Q] = trainAllGMM(goal);
    %    solution = testRL(gmm, goal-0.01, Q(:,:,gmm))
    
    solution = zeros(1, 6);
    gmm = 1;
        
    while(1)
           [solution(gmm), Q(:,:, gmm), one_rwd] = trainGMM(gmm, goal);
            if solution(gmm) ~= 0 
                %success, go to next gmm
                gmm = gmm + 1;
                if gmm == 7
                    return;
                end

            end
        end
 end