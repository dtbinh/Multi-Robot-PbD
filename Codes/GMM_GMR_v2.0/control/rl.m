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



function r = reward()