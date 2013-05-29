function [nbPC] = numPCA(path, numDemo)
    % Projection of the Data_align in a latent space using PCA.
    %Re-center the Data_align
        %read raw data
        filename = 'raw_all';
        load(filename);
        data = eval(['raw_', num2str(j)]);
        
        joint = data(1:7,:);
        hand = data(8:13,:);
        ball = data(14:16, :);

%       input = joints;
        input = data;
        
        [pc,score,latent,tsquare] = princomp(joint);
        percent = cumsum(latent)./sum(latent);
        [numDim,lenTime] = size(joint')
        for i=1:size(percent)
            if percent(i) > 0.95
                nbPC=i;
            break;
            end
        end
        fprintf('Number of PC: %d\nPercentage: %f\n',nbPC,percent(nbPC));
        meanMatrix = repmat(mean(joint,2), 1, numDim);
        centered = joint - meanMatrix;
        %Extract the eigencomponents of the covariance matrix 
        [E,v] = eig(cov(centered));
        %E = fliplr(E);
        %Compute the transformation matrix by keeping the first nbPC eigenvectors
        A = E(:, end:-1:end-nbPC+1);
        save([path,'vector.mat'], 'E');
        save([path,'meanMatrix.mat'], 'meanMatrix');
    
%     for j = 1 : numDemo
%         %read raw data
%         filename = ['raw_', num2str(j)];
%         load(filename);
%         data = eval(['raw_', num2str(j)]);
%         
%         joints = data(1:7,:);
%         hand = data(8:13,:);
%         ball = data(14:16, :);
%         input = data;
%         meanMatrix = repmat(mean(input,2), 1, numDim);
%         centered = input - meanMatrix;
% 
%         %Project the Data_align in the latent space
%         result = centered * A;
%        % plot(result(:,1), result(:,2));hold on;
%         %save low dimention projection reduced_number
%         eval(['reduced_', num2str(j), '= result;']);
%         eval(['save(''',path,'reduced_', num2str(j), '.mat'', ', '''reduced_', num2str(j), ''');']);
%     end
    
end