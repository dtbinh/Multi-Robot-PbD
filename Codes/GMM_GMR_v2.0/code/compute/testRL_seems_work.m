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
            for ite = 1 : 20
                s = readState(joint, goal(time));
                a = greedy(Q(s, :),1000, nbAct);
                joint = takeAction(a, joint, dof);
                
            end
            hand_test(time, :) = testForwardKinect([joint]', Jacobian);
        end
    
        plot(goal, 'r'); hold on;
        plot(goal+0.004, 'r-.'); 
        plot(goal-0.004, 'r-.');grid on;
       
        plot(hand_test(:,3), '*');
   
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
