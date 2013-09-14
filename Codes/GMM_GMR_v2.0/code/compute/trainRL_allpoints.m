function [solution, Q, accum_rwd] = trainRL(gmm, goal, nbAct)
    solution = 0;
    
    load('../data/Mu.mat');
    
    gamma = 0.8;
    lambda = 0.9;
    alpha = 0.6;
    
    nbGMM = 6;
    %nbAct = 12;
    nbSta = 5;
    dof = 1;

    for i = 1 : nbGMM
        range(1, i) = floor(Mu(1, i)) - 5;
        range(2, i) = floor(Mu(1, i)) + 5;
    end
    
    a = unidrnd(nbAct); % value 1~8
    
    Q = rand(power(nbSta, 7), nbAct);
    e = zeros(size(Q));
            
    total_step = 0;
    step = 0;
    total_rwd = 0;
    follow = 0;
    Mu_std = Mu;

    for episode = 1 : 2000
        step = 0;
        for time = 1 : 100
            total_step = total_step + 1;
            step = step + 1;
            fprintf('episode %d, total_step %d\n', episode,total_step);
            fprintf('gmm %d, time %d\n', gmm, time);
            m_row = 1+dof;
            m_col = gmm;
            
            
            
            
            % take action a, update Mu_new
            Mu_new = takeAction(a, Mu, m_row, m_col, nbAct);
            Mu_new(2,:)
                
            idx_Mu = index(Mu, gmm, goal);
            idx_Mu_new = index(Mu_new, gmm, goal);
            % observe rewrad in the new state
            rwd = reward(idx_Mu_new);
            total_rwd = total_rwd + rwd;
            accum_rwd(total_step) = total_rwd / total_step;
            
            % take greedy new action
            a_new = greedy(Q(index(Mu_new, gmm, goal),:), step, nbAct);

           if rwd == 1
                follow = follow + 1;
                pause;
            else
                follow = 0;
           end
            
            
            delta = rwd + gamma * Q(idx_Mu_new, a_new) - Q(idx_Mu, a);
            e(idx_Mu, a) = e(idx_Mu, a) + 1; 
            % update Q, e
            Q(:,:) = Q(:,:) + alpha * delta * e(:,:);
            e(:,:) = gamma * lambda * e(:,:);

            Mu = Mu_new;
            a = a_new;
            
            follow
            accum_rwd(total_step)
            if follow >= 100 %range(2, gmm) - range(1, gmm) 
                fprintf('Success !!! gmm %d', gmm);
                solution = a;
               return;
            end
            
            decode(idx_Mu)
            a
            a_new
           
        end
    end
end

function best = greedy(Q, total_step, nbAct)
    epsilon = 0.3;
    a = find(Q==max(Q));
    best = a;
    if size(a, 2) ~= 1 
        fprintf('Multiple max in Q: a %d, size of a %d\n', a, size(a));
        best = a(unidrnd(size(a,2)));
    end
    
    if total_step == 1
        temperature = 1/ 5;
    else
    temperature = 1 / (total_step*3);
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

function Mu_new = takeAction(a, Mu, row, col, nbAct)
   Mu_new = Mu;
  
   a = a - floor(nbAct/1.1);
   
   %gap = (max(Mu(row,:)) - min(Mu(row,:)) )/6;
   Mu_new(row, col) = Mu(row, col) + a * 0.04; %0.0406
   fprintf('chaning... %f\n', Mu_new(row, col));
end

function x = decode(a)
    base =5;
    nbState = 7;
    x = zeros(1, nbState);
    a = a - 1;
    for i = nbState : -1 :1
        x(i) = mod(a, base) + 1;
        a = fix(a/base);
    end
end

function val = code(s)
    base = 5;
    s = fliplr(s);
    val = 0;
    for i = size(s, 2) :-1: 1
        val = val + (s(i)-1) * power(base, i-1);
    end    
    val = val + 1;
end

function result = index(Mu, gmm, goal)

    range(1) = floor(Mu(1, gmm)) - 3;
    range(2) = floor(Mu(1, gmm)) + 3;
        Jacobian = forwardKinect();

    j = 1;
    for queryTime = range(1) : range(2)
        joint = GMRwithParam(queryTime, [1], [2:9], Mu);
        hand = testForwardKinect([joint]', Jacobian);
        dist = hand(3) - goal;
        
        err = 0.008;
        if queryTime < 32 || queryTime > 172
            if dist > err * 20                            % too far
                state = 5
            elseif dist <= err*20 && dist > err * 10    % a little far
                state = 4;  
            elseif dist <= err * 10 && dist > err * 2   % good
                state = 3;
            elseif dist <= err *2  && dist >err         % a little close
                state = 2;
            else
                state = 1;                                  % too close
            end
        else
            if dist > err * 2                       % too far
                state = 5;
            elseif dist <= err * 2 && dist > err  % a little far
                state = 4;
            elseif dist <= err && dist > 0-err    % good
                state = 3;          
            elseif dist <= -err && dist>-err*2    % a little tight
                state = 2;  
            else                                      % too tight, friction
                state = 1;               
            end
        end
        
        string(j) = state;
        j = j + 1;
    end
    
    result = code(string);
end

function r = reward(index_Mu)
    string = decode(index_Mu);
	if all(string) == 3		%desired
		r = 1;
    else
        r = -1;    %too far or too close
    end
end
