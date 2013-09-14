function plot_accum()

    Q = zeros(5,3,10);
    
    accum=zeros(10,3000);
    for ite = 1 : 1
        [total_step, Q, rwd] = trainRL(); 
%         for i = 1 : size(rwd, 2)
%             accum(ite, i) = rwd(i);
%         end
        plot(rwd)
    end
    
    
    plot(sum(accum,1), 'LineWidth', 3); hold on;
        xlabel('Episode', 'fontsize', 40);
        ylabel('Accumulated Reward', 'fontsize', 40);

end