% Read raw data in Time*Dim format

numDemo = 3;
input = textread('demo_1');
[Time, Dimension] = size(input);
demo(Time, Dimension, numDemo) = 0;

demo(:,:,1) = input;
demo(:,:,2) = textread('demo_2');
demo(:,:,3) = textread('demo_3');

% select the refereced demo by number
refnum = 1;
Ref = demo(:,:,refnum);

% align all other demo to reference demo
for i = 1:numDemo
    if i ~= refnum
        [Dist, D, k, w,new] = dtwMD(Ref,demo(:, :, i));
        % figure;
        % plot(demo(dim,:),'k*-'); hold on; plot(demo2(dim,:),'b.-'); hold on;plot(new,'ro-');
    end
end

% Assemble aligned demos to a file
Data = demo(:,:,1);
for i = 2:numDemo
    Data = [Data; demo(:,:,i)];
end

% Transpose to Dim * Tim for GMR
Data = Data';
save('../data/aligned_drawA.mat', 'Data');