demo1 = textread('demo_1');
demo2 = textread('demo_2');
demo3 = textread('demo_3');

demo1 = demo1';
demo2 = demo2';
demo3 = demo3';

[Dimension, Time] = size(demo1);
for dim = 1:Dimension
    [Dist, D, k, w,new] = dtwMD(demo1(dim,:),demo2(dim,:));
   % figure;
  %  plot(demo1(dim,:),'k*-'); hold on; plot(demo2(dim,:),'b.-'); hold on;plot(new,'ro-');
    demo2(dim,:) = new;
end

for dim = 1:size(demo1, 1)
    [Dist, D, k, w,new] = dtwMD(demo1(dim,:),demo3(dim,:));
%    figure;
 %   plot(demo1(dim,:),'k*-'); hold on; plot(demo3(dim,:),'b.-'); hold on;plot(new,'ro-');
    demo3(dim,:) = new;
end
t_step = 1:Time;
demo1 = [t_step; demo1];
demo2 = [t_step; demo2];
demo3 = [t_step; demo3];
Data = [demo1, demo2, demo3]';

save('drawA_reprod.mat', 'Data');
