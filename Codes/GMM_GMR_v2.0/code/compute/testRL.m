function testRL(goal, Q, nbAct)
                
    load('../data/Mu.mat');
    Jacobian = forwardKinect();

    dof = 1;
    Mu_new = Mu;
    

    Jacobian = forwardKinect();
    for queryTime = 1 : 200
        joint_traj(:, queryTime) = GMRwithParam(queryTime, [1], [2:9], Mu);
        hand6D = testForwardKinect([joint_traj(:, queryTime)]', Jacobian);
        handZ(queryTime) = hand6D(3);
    end
    joint = joint_traj(:,1);
   
        for time = 1 : 200
            for ite = 1 : 16
                s = readState(joint, goal);
                a = greedy(Q(s, :),1000, nbAct);
                joint = takeAction(a, joint, dof);
                
            end
            hand_test(time, :) = testForwardKinect([joint]', Jacobian);
        end
    
        plot(goal*ones(1,200), 'r'); hold on;
        plot(goal*ones(1,200)+0.008, 'r-.'); 
        plot(goal*ones(1,200)-0.008, 'r-.');grid on;
       
        plot(hand_test(:,3), '*');
   
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
    if rand(1,1) > epsilon * temperature
		return;
	else
		non_best = unidrnd(nbAct);
		while non_best == best
			non_best = unidrnd(nbAct);
		end
		best = non_best;
		return;
    end
end

function joint_new = takeAction(a, joint, dof)
    joint_new = joint;
    switch a
        case 1
            a = -1;
        case 2
            a = 0;
        otherwise
            a = 1;
    end 
    
    joint_new(dof) = joint(dof) + a * 0.06;   
    
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

function result = index(joint)
    Jacobian = forwardKinect();
    hand6D = testForwardKinect(joint, Jacobian);
    handZ = hand6D(3);
    dist = handZ - goal;
    
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

function s = readState(joint, goal)
    Jacobian = forwardKinect();
    hand6D = testForwardKinect(joint', Jacobian);
    handZ = hand6D(3);
    dist = handZ - goal;
    
    err = 0.005;
    if dist < -err * 2
        s = 1;
    elseif dist < -err && dist >= -err*2
        s = 2;
    elseif abs(dist) < err
        s = 3;
    elseif dist > err && dist <= err*2
        s = 4;
    else
        s = 5;
    end
end

function r = reward(s)
    if s == 1 || s == 5
        r = -1;
    elseif s == 2 || s == 4
        r = 0;
    else
        r = 1;
    end
end
