load('data/Mu.mat');
length = 150;
Jacobian = forwardKinect();
queryTime = [1:150];
hand= zeros(length, 6);
hand_new = zeros(size(hand));

Mu_new = Mu;
for i = 1 : length
    joint = GMRwithParam(queryTime, [1], [2:9], Mu);    
    joint_new = GMRwithParam(queryTime, [1], [2:9], Mu_new);

    hand(i, :) = testForwardKinect([joint(:, i)]', Jacobian);
    hand_new(i, :) = testForwardKinect([joint_new(:, i)]', Jacobian);
end
goal = hand(:, 3);
goal(40:120) = 0.325;

plot(goal, 'r'); hold on;
plot(hand(:, 3), 'g');
hold on;
plot(hand_new(:,3));