function [prinDim, unprinDim, Data2, A, Data3, rest_A] = DR(Data, nbPC)
    [nbVar,nbData] = size(Data);
    
    prinDim = zeros(1, nbPC);
   
    %Re-center the data
    %Data_mean = repmat(mean(Data,2), 1, nbData);
    %centeredData = Data - Data_mean;
    centeredData = Data;
    %Extract the eigencomponents of the covariance matrix 
    [E,v] = eig(cov(centeredData'));
    E = fliplr(E);
    %Compute the transformation matrix by keeping the first nbPC eigenvectors
    A = E(:,1:nbPC);
    rest_A = E(:,nbPC+1:end);
    %Project the data in the latent space

    Data2 = A' * centeredData;
    Data3 = rest_A' * centeredData;
    a = abs(A');
    A
    rest_A
    %importantDim = zeros(size(a,1));
    for i = 1: size(a,1)
        prinDim(i) = find(a(i, :)==max(a(i, :)));
    end
    
    j = 1;
    for i = 1 : nbVar
        if ismember(i, prinDim) == 0
           tmp = [i, sum(a(:,i))];

            if j == 1
                unprinDim = tmp;
            else
                unprinDim = [unprinDim; tmp];
            end
            j = j + 1;
        end
    end
    
    unprinDim = sortrows(unprinDim,2);

end