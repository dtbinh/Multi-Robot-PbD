function Mu = rl(Mu, DoFs)
    gamma = 0.8;
    lambda = 0.9;
    alpha = 0.6;
    epsilon = 0.3;
    
    [nbVar, nbState] = size(Mu);
    nbRange = 5;
        
    % initilize Q, e
    Q = rand([power(nbRange, nbState), power(3, nbState)]);
    e = zeros(size(Q));
   
    Jacobian = forwardKinect();

    % training
    % each episode
    for episode = 1 : 1000
       
        %initialize s, a
        s = 3 * ones(1, nbState);
        s_new = zeros(size(s));
        a = ones(1, nbState);
        a_new = zeros(size(a));
        
        % repeat for each step in one episode (update one data point)
        for step = 1 : 200
            fprintf('episode %d, step %d\n', episode, step);                     
            % take action a, 0:stay, 2:increase, 3:decrease, get s_new
            for j = 1 : nbState
                if a(j) == 1
                    s_new(j) = s(j);
                elseif a(j) == 2
                    s_new(j) = s(j) + 1;
                elseif a(j) == 3
                    s_new(j) = s(j) - 1;
                else
                    disp('Wrong action!');
                end
            end
            % observe reward
            rwd = reward(Mu, DoFs, s_new, Jacobian);
            %fprintf('rwd %f\n', rwd);

            if rwd >= 0
                follow_counter = follow_counter + 1;
            else
                follow_counter = 0;
            end

            % choose a_new, greedy
            a_new = greedy(s_new,Q);

            delta = rwd + gamma * Q(indexS(s_new), indexA(a_new)) - Q(indexS(s), indexA(a));
            e(indexS(s), indexA(a)) = e(indexS(s), indexA(a)) + 1; 
            % update Q, e
            Q = Q + alpha * delta * e;
            e = gamma * lambda * e;
            
            s = s_new;
            a = a_new;

        end 
    end %each episode while(1)

    %save('data/Mu.mat', 'Mu');
end

function val = indexS(s)
    % base = nbRange
    base = 5;
    s = fliplr(s);
    val = 0;
    for i = size(s, 2) :-1: 1
        val = val + (s(i)-1) * power(base, i-1);
    end    
    val = val + 1;
end

function val = indexA(a)
    % base = # of action directions
    base = 3;
    s = fliplr(s);
    val = 0;
    for i = size(s, 2) :-1: 1
        val = val + (s(i)-1) * power(base, i-1);
    end    
    val = val + 1;
end

function a = greedy(s, Q)
    for i = 1 : size(s, 2)
        % highest level
        if s(i) == 1
            if Q(index(s(i)), 1) > Q(index(s(i)), 3)
                a = 1;  %stay
            else
                a = 3;  %decrease
            end
        % lowest level
        elseif s(i) == 5       
            if Q(index(s(i)), 1) > Q(index(s(i)), 2)
                a = 1;  %stay
            else
                a = 2;  %increase
            end
        else
            line = Q(index(s(i)),:);
            a = find(line==max(line));
        end
    end
end

function r = reward(Mu, DoFs, s, Jacobian)
    nbState = size(s, 2);
    step  = (max(Mu(1+DoFs, :)) - min(Mu(1+DoFs, :))) / nbState;
    state(1, :) = Mu(1+DoFs, :) + 2 * step ;
    state(2, :) = Mu(1+DoFs, :) + step ;
    state(3, :) = Mu(1+DoFs, :);
    state(4, :) = Mu(1+DoFs, :) - step ;
    state(5, :) = Mu(1+DoFs, :) - 2 * step ;

    for i = 1 : nbState
         path(i) = state(s(i), i); 
    end
    Mu_new = Mu;
    Mu_new(1+DoFs, :) = path;
    
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
    for i = 100:110
        %fprintf('hand(%d, 3): %f\n', i, hand(i, 3));
        if hand(i, 3) > goal+0.01 || hand(i, 3) < goal - 0.01
            r = -1;
            break;
        %else
        %    pause;
        end
    end
end