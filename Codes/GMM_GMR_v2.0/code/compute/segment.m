function result = segment(gmm)  

    for step = 1 : 200
        beta(:, step) = GMR_influence(step, [1], [2:9]);
    end
    
for i = 1 : 6    
    plot(beta(i,:)); hold on;
end
    j = 1;
    for step = 1 : 200
        if beta(gmm ,step) > 0.9
           array(j) = step;
           j = j + 1;
        end
    end

    
    result = [min(array), max(array)];
end