%    clc;
%    clear;
%     path = 'data/';
%     numDemo = 3;
%     numDim = 14;    % 3 ball position + 3 hand position + 8 joint angles (RSholderPitch, RShoulderRoll, RElbowYaw, RElbowRoll, RwristYaw, RHand, LHip, RHip)
% 
%     delete('data/*.mat');
%     flagDTW = 1;
%     readAll(path, numDemo, numDim, flagDTW);
     



    load('data/raw_2.mat');
    tmp = raw_2';    
    hand = tmp(1:6, :);
    joint = tmp(7:end, :);
    
    length = size(tmp,2);
    
    gap = fix(length/7);
   
    
    for i = 1 : 8
        select = gap *i - (gap - 1)
        if i==8
            if select > length
                select = length
            end
        end
        h(:, i) = hand(:, select);
        j(:, i) = joint(:, select);
    end
    j = j';
    
    
    for i = 1 : 6
     A(i, :, :) = inv(j) * h(i, :)';
    end
     
    A
    
    % compare results
    for dim = 1 : 6
        for i = 1:length
            result(i) = joint(:, i)' * A(dim, :, :)';
        end
     
        figure;
        plot(result, 'ro'); hold on;
  
     plot(hand(dim, :), 'g');
     end

    