
function Jacobian = forwardKinect_regress()
    load('../data/raw_all.mat');
    tmp = raw_all';    
    hand = tmp(1:6, :);
    joint = tmp(7:end, :);

    X = [ones(size([joint(1,:)]')) [joint(1,:)]' [joint(2, :)]' [joint(3,:)]' [joint(4,:)]' [joint(5,:)]' [joint(6,:)]' [joint(7,:)]' [joint(8,:)]'];
    Y = hand';
    for i = 1 : 6
        [Jacobian(:,i), bint] = regress(Y(:,i), X, 0.1);
        bint
    end
    
   length = size(tmp, 2);
   result = zeros(3, length);
   for dim = 1 : 3
        for i = 1:length
            result(dim, i) = [joint(:, i)]' * Jacobian(2:end, dim) + Jacobian(1, dim);
        end
   end
        
    figure;
    plot3(result(1, 1:200), result(2, 1:200), result(3, 1:200)); 
    grid on;
    %plot(result, 'b*'); hold on;
    %plot(hand(dim, :), 'g');
   
end