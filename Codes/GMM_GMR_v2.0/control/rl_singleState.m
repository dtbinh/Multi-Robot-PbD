%function Mu = rl(Mu, DoFs)
function Mu = rl()
    load('data/Mu.mat');
    DoFs = 1;
    gamma = 0.8;
    lambda = 0.9;
    alpha = 0.6;
    epsilon = 0.3;
    
    [nbVar, nbState] = size(Mu);
    nbRange = 5;
        
    % initilize Q, e

   
    Jacobian = forwardKinect();
    % training
    % each episode
    %for j = 1 : nbState
     for j = 2:2   
        Q = rand([nbRange, 3]);
        e = zeros(size(Q));

        for episode = 1 : 1000
            %initialize s, a
            s = 3;
            s_new = 0;
            a = 3;
            a_new = 0;
            totalStp = 0;
            follow_counter = 0;
            accumRwd = 0;

            % repeat for each step in one episode (update one data point)
            while(1)
                totalStp = totalStp + 1;
                fprintf('episode %d, step %d\n', episode, totalStp);
                % take action a, 0:stay, 2:increase, 3:decrease, get s_new
                if a == 1
                    s_new = s;
                elseif a == 2
                    s_new = s + 1;
                elseif a == 3
                    s_new = s - 1;
                else
                    disp('Wrong action!');
                end

                % observe reward
                rwd = reward(Mu, DoFs, j, s_new, Jacobian);
                accumRwd = (accumRwd + rwd) / totalStp;
                
                %fprintf('rwd %f\n', rwd);

                if rwd >= 0
                    follow_counter = follow_counter + 1;
                else
                    follow_counter = 0;
                end

                % choose a_new, greedy
                a_new = greedy(s_new,Q);
                fprintf('s_new %d, a_new %d\n', s_new, a_new);
                delta = rwd + gamma * Q(s_new, a_new) - Q(s, a);
                e(s, a) = e(s, a) + 1; 
                % update Q, e
                Q = Q + alpha * delta * e;
                e = gamma * lambda * e;

                Q
                e
                s = s_new;
                a = a_new;
                
                if follow_counter > 10
                    pause;
                    break;
                end
                follow_counter
            end 
        end %each episode while(1)
    %save('data/Mu.mat', 'Mu');
     end
    
end

function a = greedy(s, Q)
    % highest level
    if s == 1
        if Q(s, 1) > Q(s, 2)
            a = 1;  %stay
        else
            a = 2;  %increase
        end
    % lowest level
    elseif s == 5       
        if Q(s, 1) > Q(s, 3)
            a = 1;  %stay
        else
            a = 3;  %decrease
        end
    else
        line = Q(s,:);
        candidate = find(line==max(line));
        if size(candidate, 2) ~= 0
           a = candidate(randi(size(candidate ,2), 1)); 
        else
            a = candidate;
        end
    end
end

function r = reward(Mu, DoFs,j, s, Jacobian)
    nbState = size(s, 2);
    step  = (max(Mu(1+DoFs, :)) - min(Mu(1+DoFs, :))) / nbState * 2;
    state(1) = Mu(1+DoFs, j) - 2 * step ;
    state(2) = Mu(1+DoFs, j) - step ;
    state(3) = Mu(1+DoFs, j);
    state(4) = Mu(1+DoFs, j) + step ;
    state(5) = Mu(1+DoFs, j) + 2 * step ;

    Mu_new = Mu;
    Mu_new(1+DoFs, j) = state(s);
    
    goal = 0.32;
    queryTime = [1:200];
    joint = GMRwithParam(queryTime, [1], [2:9], Mu_new);
    
    for i = 50 : 100
        hand(i, :) = testForwardKinect([joint(:, i)]', Jacobian);
    end
%    figure;
%    plot(hand(:, 3));
%    pause;
    r = 0;
    % estimated hand pos between [goal-0.5, goal+0.5]
    for i = 40:170
        %fprintf('hand(%d, 3): %f\n', i, hand(i, 3));
        if hand(i, 3) > goal+0.01 || hand(i, 3) < goal - 0.01
            r = -1;
            break;
        %else
        %    pause;
        end
    end
end