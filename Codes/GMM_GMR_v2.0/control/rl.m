%function Mu = rl(Mu, DoFs)
function Mu = rl()
    load('data/Mu.mat');
    DoFs = 1;
       
    % params
    nbRange = 5;
    gamma = 0.8;
    lambda = 0.9;
    alpha = 0.6;
    epsilon = 0.3;
        
    Jacobian = forwardKinect();
    nbState = size(Mu, 2);
    joint_mu_matrix = zeros(nbRange, nbState);
    step  = (max(Mu(1+DoFs, :)) - min(Mu(1+DoFs, :))) / nbState;
    for i = 1 : nbState
        joint_mu_matrix(1, i) = Mu(1+DoFs, i) - 2 * step;
        joint_mu_matrix(2, i) = Mu(1+DoFs, i) - step;
        joint_mu_matrix(3, i) = Mu(1+DoFs, i);
        joint_mu_matrix(4, i) = Mu(1+DoFs, i) + step;
        joint_mu_matrix(5, i) = Mu(1+DoFs, i) + 2 * step;
        
    end
    
    % initilize Q, e
    Q = rand([power(nbRange, nbState), power(nbRange, nbState)]);
    e = zeros(size(Q));
   

    % training
    % each episode
    for episode = 1 : 1000
        %initialize s, a to 0
        s = 3 * ones(1, nbState);
        s_new = zeros(size(s));
        a = randi(nbRange, [1, nbState]);
        a_new = zeros(size(a));

        % repeat for each step in one episode
        %step = 0;
        for step = 1 : 200
            fprintf('episode %d, step %d\n', episode, step);      
            
            % take action from 1 ~ nbRange, observer new state
            s_new = a;
            % observe reward
            rwd = reward(Mu, DoFs, s_new, joint_mu_matrix, Jacobian);
            %fprintf('rwd %f\n', rwd);

            if rwd >= 0
                follow_counter = follow_counter + 1;
            else
                follow_counter = 0;
            end

            % choose a_new, greedy
            a_new = greedy(s_new,Q);

            delta = rwd + gamma * Q(index(s_new), index(a_new)) - Q(index(s), index(a));
            e(index(s), index(a)) = e(index(s), index(a)) + 1; 
            % update Q, e
            Q = Q + alpha * delta * e;
            e = gamma * lambda * e;
            
            s = s_new;
            a = a_new;

        end 
    end %each episode while(1)

    %save('data/Mu.mat', 'Mu');
end

function val = index(s)
    base = 5;
    s = fliplr(s);
    val = 0;
    for i = size(s, 2) :-1: 1
        val = val + (s(i)-1) * power(base, i-1);
    end    
    val = val + 1;
end

function x = decode(a)
    x = zeros(1, 6);
    a = a - 1;
    for i = 6 : -1 :1
        x(i) = mod(a, 5) + 1;
        a = fix(a/5);
    end

end

function a = greedy(s, Q)
    line = Q(index(s), :);
    a = find(line==max(line));
    a = decode(a);
end

function r = reward(Mu, DoFs, s, joint_mu_matrix, Jacobian)   
    nbState = size(Mu, 2);
    Mu_new = Mu;
    for i = 1 : nbState
        Mu_new(1+DoFs, i) = joint_mu_matrix(s(i), i);
    end
    goal = 0.32;
    queryTime = [1:200];
    joint = GMRwithParam(queryTime, [1], [2:9], Mu_new);
    
    for i = 1 : 200
        hand(i, :) = testForwardKinect([joint(:, i)]', Jacobian);
    end
   % figure;
   % plot(hand(:, 3));
   % pause;
    r = 0;
    % estimated hand pos between [goal-0.5, goal+0.5]
    for i = 40:160
        %fprintf('hand(%d, 3): %f\n', i, hand(i, 3));
        if hand(i, 3) > goal+0.01 || hand(i, 3) < goal - 0.01
            r = -1;
            break;
        %else
        %    pause;
        end
    end
end