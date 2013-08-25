function Mu = rl(Mu)
    [nbVar, nbState] = size(Mu);
    i = 3;
    step  = (max(Mu(i, :)) - min(Mu(i, :))) / nbState;
    
    Mu(i, : ) = Mu(i, :) + step
    
    save('data/Mu.mat', 'Mu');
end