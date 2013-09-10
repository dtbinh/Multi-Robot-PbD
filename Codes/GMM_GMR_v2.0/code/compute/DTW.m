    %DTW
    function Data = DTW(Data, length)
        disp('Align raw_all with DTW.');
        [w, new] = dtwMD([Data(:, length+1:2*length)]', [Data(:,1:length)]');
        Data(:,length+1:2*length) = new';
        [w, new] = dtwMD([Data(:, 2*length+1:3*length)]', [Data(:,1:length)]');
        Data(:,2*length+1:3*length) = new';
        [w, new] = dtwMD([Data(:, 3*length+1:4*length)]', [Data(:,1:length)]'); 
        Data(:,3*length+1:4*length) = new';
    end