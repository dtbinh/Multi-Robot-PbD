function hand = compareHand(s)
    load('../data/Mu.mat');
    Mu_new = Mu;

    gap = 0.0406;
    %s = [3,2,4,4,2,5];
    for i = 1 : 6
        switch s(i)
            case 1
                s(i) = 0;
            case 5
                s(i) = -1;
        end
    end
    
    Mu_new(2, 1) = Mu(2, 1) + s(1) * gap;
    Mu_new(2, 2) = Mu(2, 1) + s(2) * gap;
    Mu_new(2, 3) = Mu(2, 1) + s(3) * gap;
    Mu_new(2, 4) = Mu(2, 1) + s(4) * gap;
    Mu_new(2, 5) = Mu(2, 1) + s(5) * gap;
    Mu_new(2, 6) = Mu(2, 1) + s(6) * gap;

    length = 200;
    
    Jacobian = forwardKinect();
    hand_std = zeros(length, 6);
    for time = 1 : length
        joint = GMRwithParam(time, 1, [2:9], Mu);
        joint_new = GMRwithParam(time, 1, [2:9], Mu_new);
        
        hand_std(time, :) = testForwardKinect([joint]', Jacobian);
        hand_new(time, :) = testForwardKinect([joint_new]', Jacobian);

    end
    goal = hand_std(:, 3) - 0.02345;
    
    diff = hand_new(:,3) - hand_std(:,3);
    
    s
    plot(hand_std(:,3), 'g'); hold on;
    plot(hand_new(:,3), 'bo'); 
    plot(goal, 'r'); grid on;
    %save('../data/reproduce.mat', 'hand');
end