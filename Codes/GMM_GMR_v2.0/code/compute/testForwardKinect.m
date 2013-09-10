function result = testForwardKinect(input, Jacobian)

    joint = input;
    length = size(joint, 1);
    result = zeros(6, length);
    for dim = 1 : 6
        for i = 1:length
            result(dim, i)= joint * Jacobian(2:end, dim) + Jacobian(1, dim);
        end
     %   figure;
     %   plot(result(dim, :), 'ro'); hold on;  
     %   plot(hand(dim, :), 'g');
    end
     
  %  pause;
  %  close all;
end