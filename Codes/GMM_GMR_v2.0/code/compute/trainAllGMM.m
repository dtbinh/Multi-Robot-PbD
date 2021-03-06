function [solution, Q] = trainAllg_max()
    solution = zeros(1,6);
    load('../data/Mu.mat');
    Jacobian = forwardKinect();
    
    gamma = 0.8;
    lambda = 0.9;
    alpha = 0.6;
    
    nbGMM = 6;
    nbAct = 8;
    nbSta = 3;
    dof = 1;
    
    goal = 0.32;
    
    a = unidrnd(nbAct); % value 1~8
    
    Q = zeros(nbSta, nbAct, nbGMM);
    for i = 1 : 6
        Q(:,:, i) = rand(nbSta, nbAct);
    end
    e = zeros(size(Q));
            
    total_step = 0;
    follow = 0;
    g_max_counter = 0;
    g_max_follow = 0;
    for episode = 1 : 2000
        g_max_old = 1;
        for time = 1 : 200
            [beta, g_max] = responsibility(time);            
            if beta(g_max) < 0.99 || solution(g_max) ~=0
                disp('already trained or not confident');
            else
                total_step = total_step + 1;
                fprintf('episode %d, total_step %d, g_max %d, time %d\n', episode,total_step, g_max, time);
                m_row = 1+dof;
                m_col = g_max;
                % New GMM
                if g_max ~= g_max_old
                    % check if last GMM trained
                    if g_max_follow == g_max_counter && g_max_counter ~= 0                    
                             fprintf('Success in GMM%d. best a=%d, follow %d', g_max_old, a, g_max_follow);
                             solution(g_max) = a;
                             solution
                             if all(solution) ~= 0
                                 solution
                                 return;
                             end
                             pause;
                    end

                          % train a new GMM, initialize current g_max data
                          g_max_counter = 0;
                          g_max_follow = 0;

                          % initialize s, a
                          s = readState(Mu, time, Jacobian, goal);                     
                          a = greedy(s, Q(:,:, g_max), g_max_counter, nbAct);
                          %a = unidrnd(nbAct);
                          
                % in old GMM
                else
                        s = readState(Mu_new, time, Jacobian, goal);
                end


                    Mu_new = takeAction(a, Mu, m_row, m_col);
                    s_new = readState(Mu_new, time, Jacobian, goal);
                    rwd = reward(s_new);

                   a_new = greedy(s_new, Q(:,:, g_max), g_max_counter, nbAct);

                   if rwd == 1
                        follow = follow + 1;
                        g_max_follow = g_max_follow+1;
                        g_max_counter = g_max_counter + 1;

                    else
                        follow = 0;
                        g_max_follow = 0;
                        g_max_counter = g_max_counter + 1;
                   end


                    delta = rwd + gamma * Q(s_new, a_new, g_max) - Q(s, a, g_max);
                    e(s, a, g_max) = e(s, a, g_max) + 1; 
                    % update Q, e
                    for i = 1 : 6
                        Q(:,:, i) = Q(:,:,i) + alpha * delta * e(:,:,i) * beta(i);
                        e(:,:, i) = gamma * lambda * e(:,:,i) * beta(i);
                    end
                    s = s_new;
                    a = a_new;

                    g_max_old = g_max;
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
        %fprintf('Multiple max in Q: a %d, size of a %d\n', a, size(a));
        best = a(unidrnd(size(a,2)));
        
    end

    
%     if total_step < 200 && total_step > 0
%         if total_step ~= 1
%             temperature = 1 / (total_step-1);
%         else
%             temperature = 1 / total_step;
%         end
%     else
        temperature = 1 / total_step;
    %end
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
        elseif dist < 0.01         % too close, touch board
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
		
		return;
	end
end
