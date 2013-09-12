function [hand, joint] = reproduce()
    length = 200;

    Jacobian = forwardKinect();
    hand = zeros(length, 6);
    joint = zeros(length, 8);
    
    for time = 1 : length
        joint(time, :) = GMR(time, 1, [2:9]);
        hand(time, :) = testForwardKinect(joint(time, :), Jacobian);
    end
    
    %plot(hand(:,3));
    %save('../data/reproduce.mat', 'hand');
end