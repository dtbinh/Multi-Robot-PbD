function solution = rl()
    clc;
    clear;
    goal = 0.32;

    %[bestMu, Q] = trainAllGMM(goal);
    %    solution = testRL(gmm, goal-0.01, Q(:,:,gmm))
    
    solution = zeros(1, 6);
    gmm = 1;
    while(1)
        while(1)
                [solution(gmm), Q(:,:, gmm)] = trainGMM(gmm, goal);
                if solution(gmm) ~= 0
                    gmm = gmm + 1;
                    if gmm == 7
                        return;
                    end
                    break;
                end
                
                if all(solution) ~= 0
                    return;
                end
        end
    end
   
end