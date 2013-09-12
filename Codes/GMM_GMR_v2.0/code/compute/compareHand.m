%function hand = compareHand(s)
function hand = compareHand()
    load('../data/Mu.mat');
    Mu_new = Mu;

    gap = 0.0406;
    %s = [8,4,2,4,4,4];  %best
    s = [1,5,4,4,5,6];
    for i = 1 : 6
        switch s(i)
            case 1
                s(i) = 0;
            case 8
                s(i) = -1;
        end
    end
    
    Mu_new(2, 1) = Mu(2, 1) + s(1) * gap;
    Mu_new(2, 2) = Mu(2, 2) + s(2) * gap;
    Mu_new(2, 3) = Mu(2, 3) + s(3) * gap;
    Mu_new(2, 4) = Mu(2, 4) + s(4) * gap;
    Mu_new(2, 5) = Mu(2, 5) + s(5) * gap;
    Mu_new(2, 6) = Mu(2, 6) + s(6) * gap;
    
    Mu_new
    
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
    plot(goal, 'r'); 
    plot(goal+0.008, 'r-.'); 
    plot(goal-0.008, 'r-.');grid on;
    %save('../data/reproduce.mat', 'hand');
    %save('../data/Mu_new.mat', 'Mu_new');
end