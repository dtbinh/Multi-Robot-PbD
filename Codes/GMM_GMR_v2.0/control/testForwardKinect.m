function result = testForwardKinect(input)
   load('data/a.mat');
%    load('data/raw_1.mat');
%    tmp = raw_1';    
%    hand = tmp(1:6, :);
%    joint = tmp(7:end, :);
%    length = size(tmp, 2);
   
    joint = input;
    length = size(joint, 1);
    result = zeros(6, length);
    for dim = 1 : 6
        for i = 1:length
            result(dim, i)= joint * a(2:end, dim) + a(1, dim);
        end
     %   figure;
     %   plot(result(dim, :), 'ro'); hold on;  
     %   plot(hand(dim, :), 'g');
    end
     
  %  pause;
  %  close all;
end