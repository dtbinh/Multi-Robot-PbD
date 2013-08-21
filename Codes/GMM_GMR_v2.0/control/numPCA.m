% Compute the number of PCs
function nbPC = numPCA(input, threshold)
    input = input';
    [pc,score,latent,tsquare] = princomp(input);    
    percent = cumsum(latent)./sum(latent);
    percent
    %[numDim,lenTime] = size(input)
    for i=1:size(percent)
        if percent(i) > threshold
            nbPC=i;
        break;
        end
    end
    fprintf('numPC: %d,  Percentage: %f, threshold %f\n',nbPC, percent(nbPC), threshold);