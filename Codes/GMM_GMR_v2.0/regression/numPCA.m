function nbPC = numPCA(numDemo)
    % Compute the number of PCs
    %read raw_all data
    load('raw_all.mat');

    joint = raw_all(:,1:7);
    hand = raw_all(:, 8:13);
    ball = raw_all(:, 14:16);


    array = ['joint'; 'hand '; 'ball '];
    nuPC = [0 0 0];
    for n = 1:3
        input = eval(eval('array(n, :)'));
        [pc,score,latent,tsquare] = princomp(input);
        percent = cumsum(latent)./sum(latent)
        [numDim,lenTime] = size(input');
        for i=1:size(percent)
            if percent(i) > 0.95
                nbPC(n)=i;
            break;
            end
        end
        fprintf('numPC for %s: %d\tPercentage: %f\n',array(n, :), nbPC(n),percent(nbPC(n)));
        meanMatrix = repmat(mean(input,2), 1, numDim);
        centered = input - meanMatrix;
        %Extract the eigencomponents of the covariance matrix 
        [E,v] = eig(cov(centered));
        %E = fliplr(E);
        %Compute the transformation matrix by keeping the first nbPC eigenvectors
        A = E(:, end:-1:end-nbPC(n)+1);
        save('vector.mat', 'E');
        save('meanMatrix.mat', 'meanMatrix');
    end
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