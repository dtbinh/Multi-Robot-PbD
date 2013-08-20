% Compute the number of PCs
function nbPC = numPCA(input, threshold)
    input = input';
    nbPC = 0;
    [pc,score,latent,tsquare] = princomp(input);
    pc
    score;
    for i = 1 : 6
    sum (score(:,i))
    end
    %latent
    %tsquare;
    
    percent = cumsum(latent)./sum(latent);
    [numDim,lenTime] = size(input');
    for i=1:size(percent)
        if percent(i) > threshold
            nbPC=i;
        break;
        end
    end
    percent
    fprintf('numPC: %d,  Percentage: %f, threshold %f\n',nbPC, percent(nbPC), threshold);
