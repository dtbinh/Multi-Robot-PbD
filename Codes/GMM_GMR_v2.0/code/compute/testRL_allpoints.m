function sol_test = testRL(goal, Q, nbAct)
                
    load('../data/Mu.mat');
    Jacobian = forwardKinect();

    dof = 1;
    Mu_new = Mu;
    for gmm = 1 : 1
            for ite = 1 : 20000

            m_row = 1+dof;
            m_col = gmm;

            range(1) = floor(Mu(1, gmm)) - 3;
            range(2) = floor(Mu(1, gmm)) + 3;

            s = readState(Mu_new, range(1), Jacobian, goal);
            a = greedy(s, Q(:,:,gmm), ite, nbAct);

            Mu_new = takeAction(a, Mu_new, m_row, m_col, nbAct);

            fprintf('gmm %d, s %d, a%d\n', gmm, s, a)
           
            end
            sol_test(gmm) = a;
    end

        for time = 1 : 200
            joint = GMRwithParam(time, 1, [2:9], Mu); 
            joint_new = GMRwithParam(time, 1, [2:9], Mu_new);

            hand(time, :) = testForwardKinect([joint]', Jacobian);
            hand_new(time, :) = testForwardKinect([joint_new]', Jacobian);
        end
    
        plot(goal*ones(1,200), 'r'); hold on;
        plot(goal*ones(1,200)+0.008, 'r-.'); 
        plot(goal*ones(1,200)-0.008, 'r-.');grid on;
        plot(hand(:,3), 'g');
        plot(hand_new(:,3), '*')

end


function best = greedy(s, Q, total_step, nbAct)
    epsilon = 0.3;
    line = Q(s, :);
    a = find(line==max(line));
    best = a;
    if size(a, 2) ~= 1 
        fprintf('Multiple max in Q: a %d, size of a %d\n', a, size(a));
        best = a(unidrnd(size(a,2)));
    end
    
    if total_step == 1
        temperature = 1/ 3;
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
  
   a = a - floor(nbAct/3);
   
   %gap = (max(Mu(row,:)) - min(Mu(row,:)) )/6;
   Mu_new(row, col) = Mu(row, col) + a * 0.03; %0.0406
end

function state = readState(Mu, queryTime, Jacobian, goal)
    joint = GMRwithParam(queryTime, [1], [2:9], Mu);
    hand = testForwardKinect([joint]', Jacobian);
    
    dist = hand(3) - goal;
    if queryTime < 32 || queryTime > 172
        if dist > 0.005 * 20    % too far
            state = 5
        elseif dist > 0.005 * 10 % far
            state = 4;  
        elseif dist <= 0.005 * 10 && dist > 0.005 * 2 % good
            state = 3;
        elseif dist <= 0.005 *2  % close
            state = 2;
        else
            state = 1;          % too close
        end
    else
        if dist > 0.005 * 2     % too far
            state = 5;
        elseif dist <= 0.005 * 2 && dist > 0.005  % approach
            state = 4;
        elseif dist <= 0.005 && dist > 0-0.005
            state = 3;          % good
        elseif dist <= -0.005       % too close, friction
            state = 2;
        else
            state = 1;          % good, writing
        end
    end
end