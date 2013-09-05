%adjust lengt
function raw_all = assemble2one(path, numDemo, numDim, length, flagDTW)
    if flagDTW
     fprintf('Align to %d with DTW\n', length);
    else
     fprintf('Align to %d withOUT DTW\n', length);
    end
    
    for i = 1: numDemo
        load([path, 'raw_', num2str(i), '.mat'])
        eval(['x=raw_', num2str(i), ';']); 
        
        new = resizem(x, [length, numDim]);
        
        if i == 1
            raw_all = new;
            template = new;

        else 

            % DTW
            if flagDTW
              [w, t2] = dtwMD(new, template);
              raw_all = [raw_all; t2];
            else
              raw_all = [raw_all; new];
            end
        end
    end
    

     
    save('data/raw_all.mat', 'raw_all');
end