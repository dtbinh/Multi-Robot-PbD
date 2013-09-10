function read2mat(path, numDemo, numDim) 
    %read in raw data in origin length
    for i = 1:numDemo
        output = readRaw(path, i);
        if size(output,2) ~= numDim
            disp('Wrong read in dimensions!');
        end
    end
end


% Read raw recorded data
function [x] = readRaw(path, numDemo)
        j = numDemo;
        dataname = [path, 'demo_', num2str(j)];
        fprintf('Reading raw data from %s\t...\t', dataname);
        fidin = fopen(dataname,'r');
        line = 1;
        while ~feof(fidin)
            tline = fgetl(fidin);
            arr = [];
            if ~isempty(tline)
                [m,n] = size(tline);

                for i = 1:n
                    if (tline(i)=='['|tline(i)==']'|tline(i)==',')
                        flag = 0;
                    else
                        flag = 1;
                    end
                    if flag==1 
                        arr = [arr tline(i)];
                        y = str2double (regexp(arr,' ','split'));
                    end
                end
            x(line, :) = y;
            line = line + 1;
            end
        end
            eval(['raw_', num2str(j), '= x;']);
            eval(['save(''../data/raw_', num2str(j), '.mat'', ', '''raw_', num2str(j), ''');']);
%         if j == 1
%             raw_all = x;
%             ref = x;
%         else
%             %teleoperate all trajecotries to the same length, refering to
%             %the 1st trajectory
%             raw_all = [raw_all; imresize(x, size(ref,1)/size(x,1))];
%         end
        fprintf('Done.\n');
        
    %save each raw data into a single raw_all.mat file
    %numDemo*time by dimensions (usualy 16 DOF)
    %save('raw_all.mat', 'raw_all');
end