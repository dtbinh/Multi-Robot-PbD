function [total_step, Q, accum_rwd] = trainRL()
    solution = 0;
    goal = 0.33*ones(1, 200);
    load('../data/Mu.mat');
    
    gamma = 0.8;
    lambda = 0.9;
    alpha = 0.6;
    
    nbGMM = 6;
    nbAct = 3;
    nbSta = 5;
    dof = 1;

    Jacobian = forwardKinect();
    for queryTime = 1 : 200
        joint_traj(:, queryTime) = GMRwithParam(queryTime, [1], [2:9], Mu);
        hand6D = testForwardKinect([joint_traj(:, queryTime)]', Jacobian);
        handZ(queryTime) = hand6D(3);
    end
    
    a = unidrnd(nbAct); 
   
    Q = rand(5, nbAct);
    e = zeros(size(Q));
            
    total_step = 0;
    step = 0;
    total_rwd = 0;
    follow = 0;
    joint = joint_traj(:,1);
    dof = [1];
    for episode = 1 : 2000
        step = 0;
        for time = 1 : 200
            total_step = total_step + 1;
            step = step + 1;
            fprintf('episode %d, total_step %d, ', episode,total_step);
            if step == 1
                a_random = unidrnd(nbAct);
                joint_random = takeAction(a_random, joint, dof);
                s = readState(joint_random, goal(time))
            else
                s = readState(joint, goal(time));   
            end
            % take action a, update Mu_new
            joint_new = takeAction(a, joint, dof);
            s_new = readState(joint_new, goal(time));
            
            % observe rewrad in the new state
            rwd = reward(s_new);
            total_rwd = total_rwd + rwd;
            accum_rwd(total_step) = total_rwd / total_step;
            
           [a_new, best] = greedy(Q(s_new,:), step, nbAct);
            
           
           if rwd == 1
                follow = follow + 1;
                %pause(1);
            else
                follow = 0;
           end
            
            delta = rwd + gamma * Q(s_new, best) - Q(s, a);
            e(s, a) = e(s, a) + 1; 
            % update Q, e
            Q = Q + alpha * delta * e;
            if best == a_new
                e = gamma * lambda * e;
            else
                e = 0*e;
            end
            s = s_new;
            a = a_new;
            
            fprintf('follow %d, accum %f\n',follow, accum_rwd(total_step));
            if follow >= 1000 %range(2, gmm) - range(1, gmm) 
                fprintf('Success !!!\n');
                solution = a;
               return;
            end
           
        end
    end
end

function [result,best] = greedy(Q, total_step, nbAct)
    epsilon = 0.3;
    a = find(Q==max(Q));
    best = a;
    if size(a, 2) ~= 1 
        fprintf('Multiple max in Q: a %d, size of a %d\n', a, size(a));
        best = a(unidrnd(size(a,2)));
    end
    
    if total_step == 1
        temperature = 1/ 3;
    else
        temperature = 1 / (total_step*2);
    end
    if rand(1,1) > epsilon * temperature
        result = best;
		return;
	else
		non_best = unidrnd(nbAct);
		while non_best == best
			non_best = unidrnd(nbAct);
		end
		result = non_best;
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


function s = readState(joint, goal)
    Jacobian = forwardKinect();
    hand6D = testForwardKinect(joint', Jacobian);
    handZ = hand6D(3);
    dist = handZ - goal;
    
    err = 0.004;
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
