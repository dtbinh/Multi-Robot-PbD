function Mu = rl(Mu, DoFs)
    [nbVar, nbState] = size(Mu);
    nbDofs = length(DoFs)
    state = zeros(length(DoFs), nbState);
    step = zeros(length(DoFs),1);
    
    for i = 1 : length(DoFs)
        state(i, :) = Mu(1+DoFs(i), :);
        step(i)  = (max(state(i, :)) - min(state(i, :))) / nbState;
        
    end
    step
    state
    
    % training
    state_new = zeros(size(state));
    % each episode
    for episode = 1 : 1000
        % each step in one episode (update one data point)
        for i = 1 : size(state, 1)
            for j = 1 : size(state, 2)          
                % take action a' using greedy plicy
                a_new = greedy();
                % observe state_new
                state_new(i, j) = act(state(i, j), a_new, step(i));
                % compute reward
                rwd = reward(state_new(i,j));

                delta = rwd + gamma * Q[state_new][a_new] - Q[state][a];
                e(state, a) = gamma * lambda * e(state, a); 
                % update Q, e
                
                
            end
        end
    end
    
    
            %Mu(i, : ) = Mu(i, :) + step

    %save('data/Mu.mat', 'Mu');
end

function state_new = act(state, a, step)
    for i = 1 : size(state,1)
        for j = 1 : size(state, 2)
            if a == 1
                state_new = state(i, j) + step
            elseif a == -1
                state_new = state(i, j) - step
            end
        end
    end
end

% goal = 0.32;
% 
% function r = reward(joint, goal)
%     hand = testForwardKinect(joint);
%     % estimated hand pos between [goal-0.5, goal+0.5]
%     if hand(3) < goal+0.005 && hand(3) > goal - 0.005
%         r = 1.0
%     else
%         r = 0
%     end
% end