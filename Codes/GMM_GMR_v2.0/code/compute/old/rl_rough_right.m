function Mu = rl()
    clc;
    clear;
    
    load('../data/Mu.mat');
    sim_hand = reproduce();
    goal = sim_hand(:, 3) - 0.02345;
    Jacobian = forwardKinect();

    nbGMM = 6;
    nbAct = 8;
    nbSta = 3;
    dof = 1;
    
    gamma = 0.8;
    lambda = 0.1;
    alpha = 0.6;
    
    for i = 1 : 6
        %range(:, i) = segment(i);
        range(1, i) = floor(Mu(1, i)) - 5;
        range(2, i) = floor(Mu(1, i)) + 5;
    end
    
    a = unidrnd(nbAct); % value 1~8
    s = 0;
    
    Q = rand(nbSta, nbAct, nbGMM);
    e = zeros(size(Q));
            
    for gmm = 5 : 5
        total_step = 0;
        range(1, gmm)
        range(2, gmm)

        for episode = 1 : 1000
            follow = 0;
            fail = 0;
            for time = range(1, gmm) : range(2, gmm)
                total_step = total_step + 1;
                fprintf('episode %d, time %d, total_step %d\n', episode, time, total_step)
                m_row = 1+dof;
                m_col = gmm;
                 if time == range(1,gmm)
%                     a = unidrnd(nbAct);
%                     Mu_new = takeAction(a, Mu, m_row, m_col);
                     s = readState(Mu, time, Jacobian, goal(time));                     
                     a = greedy(s, Q(:,:,gmm), total_step, nbAct);
                     s
                     Q(s,:,gmm)
                     a
                     
                 else
                    s = readState(Mu_new, time, Jacobian, goal(time));
                end
                Mu_new = takeAction(a, Mu, m_row, m_col);
                s_new = readState(Mu_new, time, Jacobian, goal(time));
                rwd = reward(s_new);

           
                
                
                a_new = greedy(s_new, Q(:,:,gmm), total_step, nbAct);
               
               if rwd == 1
                    follow = follow + 1;
                    fail = 0;
%                     s
%                     a
%                     s_new
%                     a_new
%                     follow
%                     pause
                else
                    follow = 0;
                    fail = 1;
                end
                follow
                

                delta = rwd + gamma * Q(s_new, a_new, gmm) - Q(s, a, gmm);
                e(s, a, gmm) = e(s, a, gmm) + 1; 
                % update Q, e
                Q(:,:,gmm) = Q(:,:,gmm) + alpha * delta * e(:,:,gmm);
                e(:,:,gmm) = gamma * lambda * e(:,:,gmm);
                
                s = s_new;
                a = a_new;

                if follow >= range(2, gmm) - range(1, gmm) -2
                    disp('Success !!!');
                    a
                    pause;
                    
                    for m = 1:200
                        t = GMRwithParam(m, [1], [2:9], Mu_new);
                        h(:, m) = testForwardKinect([t]', Jacobian);
                    end
                    plot(goal, 'r'); hold on;
                    plot(h(3,:), '*'); hold on;
                    pause;
                    close all;
                    return;
                end
                
                %if fail > 0
                %    break;
                %end
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
    temperature = 1 / total_step;
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
		r = 1
	elseif s_new == 2   %too close
		r = 0
	elseif s_new ==3	%too far
		r = 0 
	else
		disp('Illegal state');
		pause;
		return;
	end
end
