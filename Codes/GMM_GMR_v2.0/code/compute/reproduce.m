function [hand, joint] = reproduce(Mu)
    length = 200;

    Jacobian = forwardKinect();
    hand = zeros(length, 6);
    joint = zeros(length, 8);
    
    for time = 1 : length
        joint(time, :) = GMRwithParam(time, 1, [2:9], Mu);
        hand(time, :) = testForwardKinect(joint(time, :), Jacobian);
    end
    
    %plot(hand(:,3));
    %save('../data/reproduce.mat', 'hand');
end