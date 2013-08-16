function plotOrig()
    load('data/raw_1.mat');
    load('data/raw_2.mat');
    load('data/raw_3.mat');

    tmp1 = raw_1';
    tmp2 = raw_2';
    tmp3 = raw_3';

    % figure;
    % plotRaw(tmp1);
    % plotDist(tmp1);
    % 
    % figure;
    % plotRaw(tmp2);
    % plotDist(tmp2);
    % 
    % figure;
    % plotRaw(tmp3);
    % plotDist(tmp3);

    figure;
    plot3DBallHand(tmp1, 'r');hold on;
    plot3DBallHand(tmp2, 'b');hold on;
    plot3DBallHand(tmp3, 'g');
    xlabel('x','fontsize',16); ylabel('y','fontsize',16);
end


function plot2DBallPos(x, color)
    plot(x(1, :), [color, '-']);hold on;
    plot(x(2, :), [color, '-']);hold on;
    plot(x(3, :), [color, '-']);hold on;
end

function plot2DHandPos(x, color)
    plot(x(4, :), [color, '-']);hold on;
    plot(x(5, :), [color, '-']);hold on;
    plot(x(6, :), [color, '-']);hold on;
end


function plot3DBallHand(x, color)
    plot3(x(1, :), x(2, :), x(3, :), [color,'o']);hold on;
    plot3(x(4, :), x(5, :), x(6,:), [color, '-']);grid on;
end


function plot2DDist(x, color)
  x(4, :) = x(4, :) - x(1, :);
  x(5, :) = x(5, :) - x(2, :);
  x(6, :) = x(6, :) - x(3, :);
  
  plot(x(4, :), [color, 'o']);hold on;
  plot(x(5, :), [color, 'o']);hold on;
  plot(x(6, :), [color, 'o']);grid on;
end

