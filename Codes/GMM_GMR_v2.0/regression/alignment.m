% Read raw Data_align in Time*Dim format
clc;
clear;
path = '../data/B/';
% select reference demo
numDemo = 3;
demo_ref = readRaw(strcat(path, 'demo_1'));
[Time, Dimension] = size(demo_ref);

Data_align = demo_ref;

% align all other demo to reference demo
for i = 2:numDemo
    fprintf('Aligning %s\n',strcat(strcat(path, 'demo_'), num2str(i)));
    [w,new] = dtwMD(readRaw(strcat(strcat(path, 'demo_'), num2str(i))),demo_ref);
    %fprintf('size of new %d %d\n', size(new));
    Data_align = [Data_align; new];
    % figure;
    % plot(demo(dim,:),'k*-'); hold on; plot(demo2(dim,:),'b.-'); hold on;plot(new,'ro-');
end

% Transpose to Dim * Tim for GMR
Data_align = Data_align';
time = repmat([1:Time],1,3);
Data_align = [time;Data_align];

%plot demonstration 3D trajectory of end-effector
figure; 
plot3(Data_align(9, 1:Time), Data_align(10, 1:Time), Data_align(11, 1:Time), 'r');
hold on;
plot3(Data_align(9, 1+Time:2*Time), Data_align(10, 1+Time:2*Time), Data_align(11, 1+Time:2*Time), 'b');
hold on;
plot3(Data_align(9, 2*Time+1:end), Data_align(10, 2*Time+1:end), Data_align(11, 2*Time+1:end), 'g');
grid on;
xlabel('x','fontsize',16); ylabel('y' ,'fontsize',16); zlabel('z','fontsize',16);

% save
save(strcat(path,'aligned.mat'), 'Data_align');

