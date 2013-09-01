function Mu = rl(Mu, score)
    [nbVar, nbState] = size(Mu);
    %for i = 1 : length(score)
    for i = 1 : 1
        GMMStateIndex = score(i);
        state = MU(1+GMMStateIndex, :);
        step  = (max(sate) - min(state)) / nbState;
    
        Mu(i, : ) = Mu(i, :) + step
    end
    
    save('data/Mu.mat', 'Mu');
end

goal = 0.32;

function r = reward(joint, goal)
    hand = testForwardKinect(joint);
    % estimated hand pos between [goal-0.5, goal+0.5]
    if hand(3) < goal+0.005 && hand(3) > goal - 0.005
        r = 1.0
    else
        r = 0
    end
end