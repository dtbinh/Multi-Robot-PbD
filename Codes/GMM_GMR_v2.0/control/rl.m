function Mu = rl(Mu, DoFs)
    gamma = 0.8;
    lambda = 0.9;
    alpha = 0.6;
    epsilon = 0.3;
    
    [nbVar, nbState] = size(Mu);
    nbDoFs = length(DoFs);
    % explore 2 levels up and 2 levels down, plus orig levl
    nbRange = 5;
    step = zeros(nbDoFs,1);

    %3D matrix of state, 4D Q
    state = zeros(nbRange, nbState, nbDoFs);  
    for i = 1 : nbDoFs
        step(i)  = (max(Mu(1+DoFs(i), :)) - min(Mu(1+DoFs(i), :))) / nbState * 4;
        for j = 1 : nbState
            state(1, j, i) = Mu(1+DoFs(i), j) + 2 * step(i);
            state(2, j, i) = Mu(1+DoFs(i), j) + step(i);
            state(3, j, i) = Mu(1+DoFs(i), j);
            state(4, j, i) = Mu(1+DoFs(i), j) - step(i);
            state(5, j, i) = Mu(1+DoFs(i), j) - 2 * step(i);
        end 
    end
    
% % 2D matrix of state
%     state = zeros(nbDoFs, nbState);
%     for i = 1 : nbDoFs
%         step(i)  = (max(Mu(1+DoFs(i), :)) - min(Mu(1+DoFs(i), :))) / nbState;
%         state(i, :) = Mu(1+DoFs(i), :);
%    
%     end

    state
    step
    % initilize Q, e
    Q = zeros([size(state), 3]);
    e = Q;
    path = zeros(nbDoFs, nbState);

    
    Jacobian = forwardKinect();
    % training
    % each episode
    for episode = 1 : 1000
        fprintf('episode %d\n', episode);
        a = 1;
        % repeat for each step in one episode (update one data point)
        while(1)
            follow_counter = 0;
            for i = 1 : nbDoFs
                for j = 1 : nbState
                    fprintf('i: %d, j: %d\n', i, j);
                    for selectDoFs = 1 :nbDoFs
                        path(selectDoFs, :) = Mu(1+DoFs(selectDoFs), :);
                    end
                    % start from the orig level
                    r = 3;
                    % take action a' using greedy plicy, a='1:stay, 2:increase, 3: decrease
                    totalSteps = 2000;

                    % take action a, observe state_new
                    % act == 1, stay
                    if a == 1
                        r_new = r;
                    % act == 2, increase
                    elseif a == 2
                        r_new = r + 1;
                    % act == 3, decrease
                    elseif a == 3
                        r_new = r - 1;
                    else
                        dis('wroing actions!');
                        return;
                    end

                    state_new = state(r_new, j, i);
                    path(i,j) = state_new;    
                    Mu_new = Mu;
                    Mu_new(1+DoFs(i), :) = path(i, :);
                    %Mu - Mu_new
                    
                    % observe reward
                    rwd = reward(Mu_new, Jacobian);
                    
                    if rwd >= 0
                        follow_counter = follow_counter + 1;
                    else
                        follow_counter = 0;
                    end
                    
                    % choose a_new greedy
                    a_new = greedy(r_new, j, i, Q, totalSteps);
                    
                    delta = rwd + gamma * Q(r_new, j, i, a_new) - Q(r, j, i, a);
                    e(r, j, i, a) = gamma * lambda * e(r, j, i, a); 
                    % update Q, e
                    Q = Q + alpha * delta * e;
                    e = gamma * lambda * e;
                    
                    Mu = Mu_new;
                    a = a_new;
                end % j nbState
            end % i nbDoFs
            if follow_counter > 100
                break;
            end
            follow_counter
        end %each episode while(1)
    end
   
    

    %save('data/Mu.mat', 'Mu');
    
end

function a = greedy(r,j,i, Q, totlaSteps)
    % highest level
    if r == 1
        if Q(r, j, i, 1) > Q(r, j, i, 2)
            a = 1;  %stay
        else
            a = 3;  %decrease
        end
    % lowest level
    elseif r == 5       
        if Q(r, j, i, 5) > Q(r, j, i, 4)
            a = 1;  %stay
        else
            a = 2;  %increase
        end
    else
        line = Q(r,j,i,:);
        candidate_act = find(line==max(line));
        a = randi(max(candidate_act), 1, 1);
    end
end


function r = reward(Mu_new, Jacobian)
    Mu_new;
    goal = 0.32;
    queryTime = [1:263];
    joint = GMRwithParam(queryTime, [1], [2:9], Mu_new);
    
    for i = 1 : 263
        hand(i, :) = testForwardKinect([joint(:, i)]', Jacobian);
    end
   % figure;
   % plot(hand(:, 3));
   % pause;
    r = 0;
    % estimated hand pos between [goal-0.5, goal+0.5]
    for i = 50:200
        if hand(i, 3) < goal+0.005 && hand(i, 3) > goal - 0.005
            r = 0;
        else
            r = -1;
            break;
        end
    end
    
end