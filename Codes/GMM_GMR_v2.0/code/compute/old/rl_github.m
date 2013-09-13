%function Mu = rl(Mu, DoFs)
function Mu = rl()
clc;
clear;
    path = '../data/';
    load([path, 'Mu.mat']);

    sim_hand = reproduce();
    goal = sim_hand(:, 3) - 0.0235;


    figure;
    DoFs = 1;
 
    % params
    length = 200;
    nbState = 3; % 1-good, 2-too close, 3-too far
    nbRange = 5;
    nbAct = 3;  % 3 actions: 1-stay, 2-increase, 3-decrease
    nbGMM = size(Mu, 2);
    
    gamma = 0.8;
    lambda = 0.1;
    alpha = 0.6;
    
    Jacobian = forwardKinect();
    joint_mu_matrix = zeros(nbRange, nbGMM);
    gap  = (max(Mu(1+DoFs, :)) - min(Mu(1+DoFs, :))) / nbGMM;
    gap
    for i = 1 : nbGMM
         joint_mu_matrix(1, i) = Mu(1+DoFs, i);
         joint_mu_matrix(2, i) = Mu(1+DoFs, i) + 2 * gap;
         joint_mu_matrix(3, i) = Mu(1+DoFs, i) + 3 * gap;
         joint_mu_matrix(4, i) = Mu(1+DoFs, i) + 4 * gap;
         joint_mu_matrix(5, i) = Mu(1+DoFs, i) - gap;
    end
   
    % define states

    % initilize Q, e
    Q = rand(nbState, power(nbRange, nbGMM), length);		% 3 * 5^6
    e = zeros(size(Q));
   
    % training 5000 episode
	total_step = 0;
	accum_rwd = 0;
    for episode = 1 : 10000
    	% initialize a, s
        a = randi(nbRange, [1, nbGMM]);
        first_s_a = randi(nbRange, [1, nbGMM]);
        s = act2Mu(Mu, DoFs, first_s_a, joint_mu_matrix); % 1-good distance, 2-too close, 3-too far

        
    	follow_counter = 0;
        fail_counter = 0;
        hand = zeros(200, 6);
        train_length = 200;
        for step = 1 : train_length
            total_step = total_step + 1;
            fprintf('episode %d\t total_step %d\t step %d\t', episode, total_step, step);      
            
            
            % take action a, observer new state
            Mu = act2Mu(Mu, DoFs, a, joint_mu_matrix);
            s_new(step) = readState(step, Mu, Jacobian, goal(step));
            s_new(step)
           
            % observe reward
            rwd = reward(s_new(step));
            %fprintf('rwd %f\n', rwd);

            if rwd == 1 
                follow_counter = follow_counter + 1;
                fail_counter = 0;
            else
                follow_counter = 0;
                fail_counter = fail_counter + 1;
            end

            % choose a_new from Q table
            a_new = greedy(s_new(step), step, Q, total_step, nbRange, nbGMM);

            
            idx_a = index(a);
            idx_a_new = index(a_new);

        
            delta = rwd + gamma * Q(s_new(step), idx_a_new, step) - Q(s(step), idx_a, step);
            e(s(step), idx_a, step) = e(s(step), idx_a, step) + 1; 
            % update Q, e
            Q = Q + alpha * delta * e;
            e = gamma * lambda * e;


            accum_rwd = accum_rwd + rwd;
            fprintf('accum_rwd %f\t', accum_rwd/total_step);

            % check termination	
            fprintf('follow_counter %d\n', follow_counter);
            if follow_counter > train_length -1
                disp('Success !!!');
                fprintf('episode %d, total_step %d\n', episode, total_step);
                Mu_result = Mu;
                for i = 1 : nbGMM
                   Mu_result(1+DoFs, i) = joint_mu_matrix(a(i), i);
                end          
                for m = 1 : 200
                    t = GMRwithParam(m, [1], [2:9], Mu_result);
                    h(:, m) = testForwardKinect([t]', Jacobian);
                end
                plot(sim_hand(:,3), 'g'); hold on;
                plot(goal, 'r');hold on;
                plot(h(3, :), '*'); hold on;

                pause;
                %compareHand(s);
                %pause;
                close all;
                %save('../data/Mu_new.mat', 'Mu_new');
                return;
            end
            if fail_counter > 0
                break
            end
            
            s = s_new;
            a = a_new;
            Mu = act2Mu(Mu, DoFs, a, joint_mu_matrix);
        end % 200 steps 
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
    base = 5;
    nbGMM = 6;
    x = zeros(1, 6);
    a = a - 1;
    for i = nbGMM : -1 :1
        x(i) = mod(a, base) + 1;
        a = fix(a/base);
    end
end

function s_new = takeAction(queryTime, Mu, DoFs, a, joint_mu_matrix, Jacobian, goal)    
    Mu_new = act2Mu(Mu,DoFs, a, joint_mu_matrix);
   s_new = read(queryTime, Mu, Jacobian, goal)
end

function best = greedy(s, queryTime, Q, total_step, nbRange, nbGMM)
    epsilon = 0.3;

    line = Q(s, :, queryTime);
    a = find(line==max(line));
    best = decode(a);
    if size(a, 2) ~= 1 
        fprintf('Multiple max in Q: a %d, size of a %d\n', a, size(a));
        pause;
    end

    temperature = 1 / total_step; 
	%if total_step > 100 && total_step < 500
	%	temperature = 1 / (total_step - 99) * 2;	
	%end
	%if total_step > 500
	%	temperature = 1/(total_step - 500);	
	%end

	if rand(1,1) > epsilon * temperature || (total_step == 0)
		return;
	else
		non_best = randi(nbRange, [1, nbGMM]);
		while all(non_best - best) == 0
			non_best = randi(nbRange, [1, nbGMM]);
		end
		best = non_best;
		return;
	end
end
function Mu_new = act2Mu(Mu,DoFs, a, joint_mu_matrix)
   nbGMM = size(Mu, 2);
   Mu_new = Mu;
   for i = 1 : nbGMM
       Mu_new(1+DoFs, i) = joint_mu_matrix(a(i), i);
   end 
end
function state = readState(queryTime, Mu, Jacobian, goal)
   joint = GMRwithParam(queryTime, [1], [2:9], Mu);
   hand = testForwardKinect([joint]', Jacobian);
   dist = hand - goal;

   threshold = 0.005;
   if queryTime < 33 || queryTime > 172
		if dist > 1 * threshold 	%too far, less likely happen
			state = 3
		elseif dist < 0					%too close, touch board
			state = 2
		else
			state = 1				%legal position
	 	end
   else
		if dist > threshold			%too far
			state = 3
		elseif dist < -threshold	%too close
			state = 2
		else
			state = 1				%perfect
   		end
   end
end

function r = reward(s_new)
	if s_new == 1		%desired
		r = 1
	elseif s_new == 2   %too close
		r = -1
	elseif s_new ==3	%too far
		r = -1 
	else
		disp('Illegal state');
		pause;
		return;
	end
end
