% Read raw recorded data
function [x] = readRaw(dataname)
    fidin = fopen(dataname,'r');
    %Recorded data max step 10000, typically 16 dimensions
    col = 16;
    %x = zeros(1000,col);
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
end