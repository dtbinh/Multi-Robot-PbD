function [solution, Q] = trainOneGMM(gmm, goal)
   
    load('../data/Mu.mat');
    Jacobian = forwardKinect();
    
    gamma = 0.8;
    lambda = 0.9;
    alpha = 0.6;
    
    nbGMM = 6;
    nbAct = 8;
    nbSta = 3;
    dof = 1;
    
    for i = 1 : 6
        range(1, i) = floor(Mu(1, i)) - 3;
        range(2, i) = floor(Mu(1, i)) + 3;
    end
    
    a = unidrnd(nbAct); % value 1~8
    s = 0;
    
    Q = rand(nbSta, nbAct);
    e = zeros(size(Q));
            
    total_step = 0;
    step = 0;
    for episode = 1 : 2000
        follow = 0;
        fail = 0;
        for time = range(1, gmm) : range(2, gmm)
            total_step = total_step + 1;
            step = step + 1;
            fprintf('episode %d, total_step %d\n', episode,total_step);
            fprintf('gmm %d, time %d\n', gmm, time);
            m_row = 1+dof;
            m_col = gmm;
             if time == range(1,gmm)
                 s = readState(Mu, time, Jacobian, goal);                     
                 a = greedy(s, Q(:,:), total_step, nbAct);
             else
                s = readState(Mu_new, time, Jacobian, goal);
            end
            Mu_new = takeAction(a, Mu, m_row, m_col);
            s_new = readState(Mu_new, time, Jacobian, goal);
            rwd = reward(s_new);

            a_new = greedy(s_new, Q(:,:), total_step, nbAct);

           if rwd == 1
                follow = follow + 1;
                fail = 0;
            else
                follow = 0;
                fail = 1;
            end
            
            delta = rwd + gamma * Q(s_new, a_new) - Q(s, a);
            e(s, a) = e(s, a) + 1; 
            % update Q, e
            Q(:,:) = Q(:,:) + alpha * delta * e(:,:);
            e(:,:) = gamma * lambda * e(:,:);

            s = s_new;
            a = a_new;

            if follow >= range(2, gmm) - range(1, gmm) -2
                fprintf('Success !!! gmm %d', gmm);
                solution = a;
                solution
                pause;
                return;
            end

            if step > 400
                step = 0;
                pause(1);
                break;
            end
        end
        

    end
end

function best = greedy(s, Q, total_step, nbAct)
    epsilon = 0.3;
    line = Q(s, :);
    a = find(line==max(line));
    best = a;
    if size(a, 2) ~= 1 
        fprintf('Multiple max in Q: a %d, size of a %d\n', a, size(a));
        best = a(unidrnd(size(a,2)));
        %pause;
    end

    
    if total_step < 200 && total_step > 0
        if total_step ~= 1
            temperature = 1 / (total_step-1);
        else
            temperature = 1 / total_step;
        end
    else
        temperature = 1 / total_step;
    end
    if rand(1,1) > epsilon * temperature || (total_step == 0)
		return;
	else
		non_best = unidrnd(nbAct);
		while all(non_best - best) == 0
			non_best = unidrnd(nbAct);
		end
		best = non_best;
		return;
    end
end

function Mu_new = takeAction(a, Mu, row, col)
   Mu_new = Mu;
   if a == 1
       a = 0;
   elseif a == 8
       a = -1;
   end
   Mu_new(row, col) = Mu(row, col) + a * 0.0406;
end

function state = readState(Mu, queryTime, Jacobian, goal)
    joint = GMRwithParam(queryTime, [1], [2:9], Mu);
    hand = testForwardKinect([joint]', Jacobian);
    
    dist = hand(3) - goal;
    if queryTime < 32 || queryTime > 172
        if dist > 0.005 * 10    % too far
            state = 3;  
        elseif dist < 0         % too close, touch board
            state = 2;
        else
            state = 1;          % good
        end
    else
        if dist > 0.005         % too far, may not write down
            state = 3;
        elseif dist < -0.005    % too close, friction
            state = 2;
        else
            state = 1;          % good, writing
        end
    end
end

function r = reward(s_new)
	if s_new == 1		%desired
		r = 1;
	elseif s_new == 2   %too close
		r = 0;
	elseif s_new ==3	%too far
		r = 0;
	else
		disp('Illegal state');
		pause;
		return;
	end
end
