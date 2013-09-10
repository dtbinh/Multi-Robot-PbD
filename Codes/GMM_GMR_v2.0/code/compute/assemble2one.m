%adjust lengt
function raw_all = assemble2one(path, numDemo, numDim, length)
    for i = 1: numDemo
        load([path, 'raw_', num2str(i), '.mat'])
        eval(['x=raw_', num2str(i), ';']); 
        
        new = resizem(x, [length, numDim]);
     
        if i == 1
            raw_all = new;
        else 
            raw_all = [raw_all; new];        
        end
    end
    save([path,'raw_all.mat'], 'raw_all');
end