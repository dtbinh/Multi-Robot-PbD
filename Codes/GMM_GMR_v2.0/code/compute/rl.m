function solution = rl()
    clc;
    clear;
    goal = 0.32;
    bestMu = zeros(1, 6);
    Q = zeros(3, 8, 6);
    
    for gmm = 4 : 4
        [bestMu(gmm), Q(:,:,gmm)] = trainOneGMM(gmm, goal);
        solution = testRL(gmm, goal-0.01, Q(:,:,gmm))
    end