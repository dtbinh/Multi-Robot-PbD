%function Mu = rl(Mu, DoFs)
function Mu = rl()
    clc;
    clear;
    path = '../data/';
    load([path, 'Mu.mat']);

    sim_hand = reproduce();
    goal = sim_hand;
    goal(:, 3) = sim_hand(:, 3) - 0.0235;

	DoFs = 1;
 
    % params
    nbRange = 5;
    nbAct = 3;  % 3 actions: 1-stay, 2-increase, 3-decrease
	gamma = 0.8;
    lambda = 0.9;
    alpha = 0.6;
    
    Jacobian = forwardKinect();
    nbState = size(Mu, 2);
    joint_mu_matrix = zeros(nbRange, nbState);
    gap  = (max(Mu(1+DoFs, :)) - min(Mu(1+DoFs, :))) / nbState;
    gap
    for i = 1 : nbState
         joint_mu_matrix(1, i) = Mu(1+DoFs, i);
         joint_mu_matrix(2, i) = Mu(1+DoFs, i) + 2 * gap;
         joint_mu_matrix(3, i) = Mu(1+DoFs, i) + 3 * gap;
         joint_mu_matrix(4, i) = Mu(1+DoFs, i) + 4 * gap;
         joint_mu_matrix(5, i) = Mu(1+DoFs, i) - gap;
    end
    
    % initilize Q, e, one Q is empty
    for i = 1 : 6
        for j = 1 : 6
            if j > i
                QTable(:, :, i, j) = rand([power(nbRange, 2), power(nbAct, 2)]);
            end
        end
    end
    eTable = zeros(size(QTable));

    % initial whole state
    whole_state = ones(1, 6);
    whole_act = ones(1, 6);

    total_step = 0;
	accum_rwd = 0;
    selectDim = [0;0];
    selectDim_old = selectDim;
    
    %initialize s, a
    s = randi(nbRange, [1, 2]);		% s begins randomly 
    s_new = zeros(size(s));
    a = randi(nbAct, [1, 2]);        % select a randomly
    a_new = ones(size(a));

    for episode = 1 : 10000
        % repeat for each step in one episode
        s = randi(nbRange, [1, 2]);		% s begins randomly 
        s_new = zeros(size(s));
        a = randi(nbAct, [1, 2]);        % select a randomly
        a_new = ones(size(a));
        
		follow_counter = 0;
		fail_counter = 0;

        train_length = 50;
        for step = 70 : 70+train_length 
            total_step = total_step + 1; 
            fprintf('episode %d\t total_step %d\t step %d\t', episode, total_step, step);      
            selectDim = select(step);
            selectDim
            
            % new phase
            if ~isequal(selectDim, selectDim_old)
                s = randi(nbRange, [1, 2]);		% s begins randomly 
                s_new = zeros(size(s));
                a = randi(nbAct, [1, 2]);        % select a randomly
                a_new = ones(size(a));
                Q = QTable(:, :, selectDim(1), selectDim(2));
                e = eTable(:, :, selectDim(1), selectDim(2));
            end
            size(Q)
            size(e)
            
			% take action from 1 ~ nbRange, observer new state
            s_new = takeAction(s, a);
            
            whole_state_new = zeros(1, 6);
            whole_state_new(selectDim(1)) = s_new(1);
            whole_state_new(selectDim(2)) = s_new(2);
            
            % observe reward
            [rwd, h] = reward(step, Mu, DoFs, whole_state_new, joint_mu_matrix, Jacobian, goal(step, 3));
			
            if rwd == 1 
                whole_state(selectDim(1)) = s(1);
                whole_state(selectDim(2)) = s(2);
                whole_act(selectDim(1)) = a(1);
                whole_act(selectDim(2)) = a(2);
                
                follow_counter = follow_counter + 1;
                hand(step, :) = h';
            else
                follow_counter = 0;
				fail_counter = fail_counter + 1;
            end

                        
            fprintf('size of Q %d\n', size(Q));
            % choose a_new, greedy
            a_new = greedy(s_new, Q, step, nbRange, size(selectDim), nbAct);
            
            
            idx_s = index(s, nbRange);
            idx_s_new = index(s_new, nbRange);
            idx_a = index(a, nbAct);
            idx_a_new = index(a_new, nbAct);
            
            delta = rwd + gamma * Q(idx_s_new, idx_a_new) - Q(idx_s, idx_a);
            e(idx_s, idx_a) = e(idx_s, idx_a) + 1; 
            % update Q, e
            Q = Q + alpha * delta * e;
            e = gamma * lambda * e;
			Q(:,:, min(selectDim), max(selectDim)) = Q;
            e(:,:, min(selectDim), max(selectDim)) = e;

			accum_rwd = accum_rwd + rwd;
			fprintf('accum_rwd %f\t', accum_rwd/total_step);
			
			% check termination	
			fprintf('follow_counter %d\n', follow_counter);
			if follow_counter > train_length -1
				disp('Success !!!');
                whole_state
                fprintf('episode %d, total_step %d\n', episode, total_step);
                s
                pause;
                compareHand(whole_state);
                pause;
                close all;
				%save('../data/Mu_new.mat', 'Mu_new');
				return;
            end
            
            s = s_new;
            a = a_new;
            selectDim_old = selectDim;
			if fail_counter > 0
				break
            end

        end % 200 steps 
    end %each episode while(1)
    %save('data/Mu.mat', 'Mu');
end

function val = index(s, base)    
    s = fliplr(s);
    val = 0;
    for i = size(s, 2) :-1: 1
        val = val + (s(i)-1) * power(base, i-1);
    end    
    val = val + 1;
end

function x = decode(a)
    base =3;
    nbState = 2;
    x = zeros(1, nbState);
    a = a - 1;
    for i = nbState : -1 :1
        x(i) = mod(a, base) + 1;
        a = fix(a/base);
    end
end

%input [s1, s2] ~ 1-5, [a1, a2] ~ 1-3
function s_new = takeAction(s, a)    
    for n = 1 : size(s, 2)
        if s(n) == 1 && a(n) == 3      % min and decrease -> s=5 
            s_new(n) = 5;
        elseif s(n) == 5 && a(n) == 2  % max and increase -> s=1
			s_new(n) = 1;
		else
			switch a(n)
				case 1
					s_new(n) = s(n);
				case 2
					s_new(n) = s(n) + 1;
				case 3
					s_new(n) = s(n) - 1;
				otherwise 
					disp('Wrong action in takeAction(), hit any key to exit');
					pause;
					return;
			end
        end
    end
end

function best = greedy(s, Q, total_step, nbRange, nbState, nbAct)
    epsilon = 0.3;
	line = Q(index(s, nbRange), :);
    a = find(line==max(line));
	if size(a, 2) ~= 1 
		fprintf('Multiple max in Q: a %d, size of a %d\n', a, size(a));
        size(Q)
        
		pause;
    end
    best = decode(a);
	temperature = 1 / total_step; 
	if rand(1,1) > epsilon * temperature;
		return;
	else
		non_best = randi(nbAct, [1, nbState]);
		while all(non_best - best) == 0
			non_best = randi(nbAct, [1, nbState]);
		end
		best = non_best;
		return;
    end
end

function [r, hand] = reward(queryTime, Mu, DoFs, s, joint_mu_matrix, Jacobian, goal) 
   Mu_new = updateMu(Mu, s, joint_mu_matrix, DoFs);

   joint = GMRwithParam(queryTime, [1], [2:9], Mu_new);
	

   hand = testForwardKinect([joint]', Jacobian);
 
   %fprintf('hand %f\t, goal %f\t, diff %f\n', hand(3), goal, hand(3)-goal);
    
    if queryTime < 30 || queryTime > 171
        if hand(3) < 0.32
            r = -1;
        else
            r = 1;
        end
    else 
        if abs(hand(3) - goal) > 0.01
            r = -1;
        else
            r = 1;
            %r = 1 - abs(hand(3) - goal) * 100;
        end
    end
end

function Mu_new = updateMu(Mu,s, joint_mu_matrix, DoFs)
   nbState = size(Mu, 2);
   Mu_new = Mu;
   for i = 1 : nbState
       if s(i) ~= 0
            Mu_new(1+DoFs, i) = joint_mu_matrix(s(i), i);
       end
   end
end

function selectDim = select(step)
    beta = GMR_influence(step, [1], [2:9]);
    beta =[[1:6]',beta];
    tt = sortrows(beta, 2);
    selectDim = tt(end-1:end, 1);
    selectDim = sort(selectDim);
end