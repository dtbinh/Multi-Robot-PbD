function output = rl_hand()
    alljoint = GMR(1, [1], [2:9]);
    start = alljoint(1);

    
    sim_hand = reproduce();
    wall = sim_hand(:, 3) - 0.0235;
    
    s = 0; % 1-good, 2-too close, 3-too far
    a = 0; % 0-stay, +increase, -decrease
    
    Q = zeros(3, 5);
    e = zeros(size(Q));
    
    for episode = 100
        %reset to a random position and read s
        s = convert(start-wall(1));
        
        for queryTime = 1 : 200
            
            s_new = takeAction(a);
            
        end
        
        
    end
end


function code = convert(dist)
    if dist > 0.005
        code = 3
    elseif dist < -0.005
        code = 2;
    else
        code = 1;
    end
end