% Compute the number of PCs
function [nbPC, percent] = numPCA(input, threshold)
    input = input';
    [pc,score,latent,tsquare] = princomp(input);    
    percent = cumsum(latent)./sum(latent);
    
    
%     plot(percent, 'LineWidth', 3); hold on;
%     plot(5, percent(5), 'r.', 'MarkerSize', 30);
%     xlabel('Number of components', 'fontsize', 20);
%     ylabel('Data variance', 'fontsize', 30);
    
    %[numDim,lenTime] = size(input)
    for i=1:size(percent)
        if percent(i) >= threshold
            nbPC=i;
        break;
        end
    end
    fprintf('numPC: %d,  Percentage: %f, threshold %f\n',nbPC, percent(nbPC), threshold);

 %   labels = {'X1', 'X2', 'X3', 'X4', 'X5', 'X6', 'X7'};     
 %   biplot(pc(:, 1:3), 'Scores', score(:,1:3), 'VarLabels', ...
 %   labels, 'LineWidth', 5, 'MarkerSize', 5);

end