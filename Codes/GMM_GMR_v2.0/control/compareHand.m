    load('data/Mu.mat');
    
	Jacobian = forwardKinect();
    queryTime = [1:200];
	hand= zeros(200, 6);
	for i = 1 : 200
		joint = GMRwithParam(queryTime, [1], [2:9], Mu);
		hand(i, :) = testForwardKinect([joint(:, i)]', Jacobian);
    end
	goal = hand(:, 3);
	goal(40:160) = 0.325;
    
    
    gap = 0.0809;
%    Mu_new = Mu;
%     Mu_new(2,1) = Mu(2,1) + 0.2436;
%     Mu_new(2,2) = Mu(2,2) + 0.3248;
%     Mu_new(2,3) = Mu(2,3) ;
%     Mu_new(2,4) = Mu(2,4) + 0.2436;
%     Mu_new(2,5) = Mu(2,5) + 0.3248;
%     Mu_new(2,6) = Mu(2,6) + 0.2436;
    
    new = zeros(5, 6);
    new(1, :) = Mu(2,:) - gap;
    new(2, :) = new(1, :) + gap;
    new(3, :) = new(1, :) + 2 * gap;
    new(4, :) = new(1, :) + 3 * gap;
    new(5, :) = new(1, :) + 4 * gap;
    
    path = zeros(1, 6);
    hand = zeros(200, 6);
    hand_new = zeros(200, 6);

    for s1_r = 1 : 5
        for s2_r = 1 : 5
            for s3_r = 1 : 5
                for s4_r = 1 : 5
                    for s5_r = 1 : 5
                        for s6_r = 1 : 5
                            path(1) = new(s1_r, 1);
                            path(2) = new(s2_r, 2);
                            path(3) = new(s3_r, 3);
                            path(4) = new(s4_r, 4);
                            path(5) = new(s5_r, 5);
                            path(6) = new(s6_r, 6);
							Mu_new = Mu;
							Mu_new(2, :) = path;
                            joint_new = GMRwithParam(queryTime, [1], [2:9], Mu_new);
                            for i = 1 : 200
								hand_new = testForwardKinect([joint_new(:, i)]', Jacobian);
								if abs(hand_new(3) - goal(i)) < 0.01
                                    r = 0;
                                    Mu_new
									return
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
       
%    figure;
%    hold on;
%    plot(hand(:, 3)) ;
%    plot(hand_new(:, 3), 'r');

%    save('data/goal.mat', 'goal');
%     figure;
%     plot3(hand(:, 1), hand(:, 2), hand(:, 3)); hold on;
%     plot3(hand_new(:, 1), hand_new(:, 2), hand_new(:, 3), 'r');
%     grid on;
    %figure;
    %plot(hand(:,1));
    %figure;
    %plot(hand(:,2));

    pause;
    close all;
