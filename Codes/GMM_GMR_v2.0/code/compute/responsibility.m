function [beta, best] = responsibility(time)  
    beta = GMR_influence(time, [1], [2:9]);
    best = find (beta == max(beta));
end