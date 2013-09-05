    Jacobian = forwardKinect();

    queryTime = [1:200];
    
    Mu_new = Mu;
    Mu_new(2,1) = Mu(2,1) + 0.1;
    Mu_new(2,2) = Mu(2,2) + 0.4;
    Mu_new(2,3) = Mu(2,3) + 0.1;
    Mu_new(2,4) = Mu(2,4) + 0.4;
    Mu_new(2,5) = Mu(2,5) + 0.2;
    Mu_new(2,6) = Mu(2,6) ;
    
    joint = GMRwithParam(queryTime, [1], [2:9], Mu);
    joint_new = GMRwithParam(queryTime, [1], [2:9], Mu_new);
    hand = zeros(200, 6);
    hand_new = zeros(200, 6);
    for i = 1 : 200
        hand(i, :) = testForwardKinect([joint(:, i)]', Jacobian);
        hand_new(i, :) = testForwardKinect([joint_new(:, i)]', Jacobian);

    end
    
    figure;
    hold on;
    plot(hand(:, 3));
    plot(hand_new(:, 3), 'r');
    
%     figure;
%     plot3(hand(:, 1), hand(:, 2), hand(:, 3)); hold on;
%     plot3(hand_new(:, 1), hand_new(:, 2), hand_new(:, 3), 'r');
%     grid on;
    %figure;
    %plot(hand(:,1));
    %figure;
    %plot(hand(:,2));