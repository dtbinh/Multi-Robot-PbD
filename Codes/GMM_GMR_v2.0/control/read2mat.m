function read2mat(path, numDemo, numDim) 
    %read in raw data in origin length
    for i = 1:numDemo
        output = readRaw(path, i);
        if size(output,2) ~= numDim
            disp('Wrong read in dimensions!');
        end
    end
end