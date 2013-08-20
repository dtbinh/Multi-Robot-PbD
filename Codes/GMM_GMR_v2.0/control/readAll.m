function readAll(path, numDemo, numDim, flagDTW) 
    %read in raw data in origin length
    for i = 1:numDemo
        readRaw(path, i);
    end
    
    %adjust length
    for i = 1: numDemo
        load(['data/raw_', num2str(i), '.mat'])
        eval(['x=raw_', num2str(i), ';']); 
        if i == 1
            raw_all = x;
            ref = x;
        else 
            size(ref,1)
            new = resizem(x, [size(ref,1), numDim]);
            % DTW
            if flagDTW
              [w, t2] = dtwMD(new, raw_1);
              raw_all = [raw_all; t2];
            else
              raw_all = [raw_all; new];
            end
        end
    end
    
     if flagDTW
         disp('pre-processing by DTW');
     else
         disp('non DTW pre-processing');
     end
     
    save('data/raw_all.mat', 'raw_all');