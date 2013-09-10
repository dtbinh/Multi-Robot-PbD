    
function Jacobian = forwardKinect()
    load('../data/raw_all.mat');
    tmp = raw_all';    
    hand = tmp(1:6, :);
    joint = tmp(7:end, :);
   
    length = size(tmp, 2);
    X = [ones(size([joint(1,:)]')) [joint(1,:)]' [joint(2, :)]' [joint(3,:)]' [joint(4,:)]' [joint(5,:)]' [joint(6,:)]' [joint(7,:)]' [joint(8,:)]'];

   for i = 1 : 6
       Y = [hand(i, :)]';
       Jacobian(:, i) = X \ Y;
   end
    
%    % self-test
%     for dim = 3 : 3
%         for i = 1:length
%             result(i) = [joint(:, i)]' * Jacobian(2:end, dim) + Jacobian(1, dim);
%         end
%      
%         figure;
%         plot(result, 'ro'); hold on;
%         plot(hand(dim, :), 'g');
% 
%     end
   % test with testing data 
   % testforwardKinect(Jacobian);
    
   
   save('../data/Jacobian.mat', 'Jacobian');
   % pause;
   % close all;
end