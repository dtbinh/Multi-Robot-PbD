
length = 200;
    
    t1 = 32;
    t2 = 172;
    
%figure;
%plot3(realHand2(:, 1), realHand2(:, 2), realHand(:, 3),'r');hold on;
%plot3(realHand2(t1:t2, 1), realHand2(t1:t2, 2), realHand(t1:t2,
%3),'r');hold on;
% grid on;

% for i = 3 : 3
%     figure;
%     plot(realHand2(:,i)); hold on; plot(realHand(:,i), 'g');
% 
% end
    
    Jacobian = forwardKinect();
    hand = zeros(length, 6);
    for time = 1 : length
        joint = GMR(time, 1, [2:9]);
        hand(time, :) = testForwardKinect([joint]', Jacobian);
    end
    

    %simulated 3D
    figure;
    plot3(hand(t1:t2, 1), hand(t1:t2, 2), hand(t1:t2, 3),'r');hold on;
    plot3(hand(1:t1, 1), hand(1:t1, 2), hand(1:t1, 3));
    plot3(hand(t2:end, 1), hand(t2:end, 2), hand(t2:end, 3));
grid on; 
    xlabel('hand_1');
    ylabel('hand_2');
    zlabel('hand_3');

    % simulated Z
    %figure;
    
    %plot(hand(:, 3), 'r')
    
%     %simulated 2D -N parte only
%     figure;
%     plot(hand(t1:t2, 1), 'r');hold on;
%     figure;
%     plot(hand(t1:t2, 2), 'g');
%     figure;
%     plot(hand(t1:t2, 3), 'b');grid on;