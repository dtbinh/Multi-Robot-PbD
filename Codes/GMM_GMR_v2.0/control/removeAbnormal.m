function ballPos = removeAbnormal(input)
  warning off;
  %  load('ballPos.mat');
  %  input = ballPos;
  %  size(input)
    [idx, ctrs] = kmeans(input, 2, 'emptyaction', 'singleton');
    
    count1 = sum(idx == 1);
    count2 = sum(idx == 2);

    new = [];
    if count1 > count2
        max = 1;
    else
        max = 2;
    end
    
    new_idx = 1;

    for i = 1 : size(input, 1)
        if idx(i) == max
            new(new_idx, :) = input(i, :);
            new_idx = new_idx + 1;
        end
    end
    
    ballPos = mean(new);
end