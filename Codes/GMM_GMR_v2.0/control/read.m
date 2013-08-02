function read(path, numDemo, numDim) 
    %read in raw data in origin length
    for i = 1:numDemo
        readRaw(path, i);
    end
    %align length
    for i = 1: numDemo
        load(['data/raw_', num2str(i), '.mat'])
        eval(['x=raw_', num2str(i), ';']); 
        if i == 1
            raw_all = x;
            ref = x;
        else 
            size(ref,1)
            new = resizem(x, [size(ref,1), numDim]);
            raw_all = [raw_all; new];
        end
    end
    save('data/raw_all.mat', 'raw_all');