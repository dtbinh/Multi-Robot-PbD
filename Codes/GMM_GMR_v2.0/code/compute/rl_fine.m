function [sol_train, Q] = rl()
    clc;
    clear;
    load('../data/Mu.mat');
    nbAct = 20;
    
    length = 200;
    Jacobian = forwardKinect();
    hand_std = zeros(length, 6);
    for time = 1 : length
        joint = GMRwithParam(time, 1, [2:9], Mu);
        hand_std(time, :) = testForwardKinect([joint]', Jacobian);
    end
    
    goal = mean(hand_std(80:100, 3)) - 0.02;
    
    sol_train = zeros(1, 6);
    
        for gmm = 1 : 6
           [sol_train(gmm), Q(:,:, gmm), one_rwd] = trainGMM(gmm, goal, nbAct);
            if sol_train(gmm) ~= 0 
                %success, go to next gmm
                gmm = gmm + 1;
                if gmm == 7
                        
                end

            end
        end
        plot_train(sol_train, nbAct, goal);

 end