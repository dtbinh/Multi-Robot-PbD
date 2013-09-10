path = 'data/';

numDemo = 4;
numDim = 14;

flagDTW = 1;
length = 100;

flagDTW = 0;
raw_all = assemble2one(path, numDemo, numDim, length, flagDTW);
    
%DTW

flagDTW = 1;
raw_all = assemble2one(path, numDemo, numDim, length, flagDTW);

tmp = [raw_all(:,7:end-1)]';
onetime = [1:length];
timeDim = repmat(onetime, [1, numDemo]);
Data =[timeDim; tmp];
    
threshold = 0.98;
nbPC = numPCA(Data(2:end, :), threshold);
nbPC

[nbVar,nbData] = size(Data);

if flagDTW == 1
    disp('Align raw_all with DTW.');
    [w, new] = dtwMD([Data(:, length+1:2*length)]', [Data(:,1:length)]');
    Data(:,length+1:2*length) = new';
    [w, new] = dtwMD([Data(:, 2*length+1:3*length)]', [Data(:,1:length)]');
    Data(:,2*length+1:3*length) = new';
    [w, new] = dtwMD([Data(:, 3*length+1:4*length)]', [Data(:,1:length)]'); 
    Data(:,3*length+1:4*length) = new';
end

%Re-center the data
Data_mean = repmat(mean(Data(2:end,:),2), 1, nbData);
centeredData = Data(2:end,:) - Data_mean;
%Extract the eigencomponents of the covariance matrix 
[E,v] = eig(cov(centeredData'));
E = fliplr(E);
%Compute the transformation matrix by keeping the first nbPC eigenvectors
A = E(:,1:nbPC);
%Project the data in the latent space
nbVar2 = nbPC+1;
Data2 = zeros(size(Data));
Data2(1,:) = Data(1,:);
Data2(2:nbVar2,:) = A' * centeredData;
A'
a = abs(A');
importantDim = zeros(1, size(a,1));
size(a,1)
for i = 1: size(a,1)
    importantDim(i) = find(a(i, :)==max(a(i, :)));
end

importantDim