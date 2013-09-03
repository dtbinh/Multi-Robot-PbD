load('data/raw_all.mat');
load('data/raw_1.mat');
l = size(raw_1,1)
tmp = [raw_all(1:l, :)]';
hand = tmp(1:6, :);
joint = tmp(7:end, :);

length = size(tmp, 2);
result = zeros(length, 6);
for i = 1 : length
        result(i, :) = testForwardKinect(joint(:,i)');
        %plot3(result(1), result(2), result(3), 'ro'); hold on;
        %plot3(hand(1, i), hand(2, i), hand(3, i), 'go');
end
        figure;
        plot(result(:, 1), 'r'); hold on; plot(hand(1, :));
        figure;
        plot(result(:, 2), 'r'); hold on; plot(hand(2, :));
        figure;
        plot(result(:, 3), 'r'); hold on; plot(hand(3, :));
grid on;