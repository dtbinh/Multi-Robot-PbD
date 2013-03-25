addpath('../dtw');

demo1 = readRaw('../data/demo_1');
demo2 = readRaw('../data/demo_2');
demo3 = readRaw('../data/demo_3');
load('../data/reproduce_drawB.mat');

x = 10;
y = 9;
z = 8;

plot3(demo1(:,x), demo1(:,y), demo1(:,z),'b'); 
hold on; 
plot3(demo2(:,x), demo2(:,y), demo2(:,z),'r'); 
hold on; 
plot3(demo3(:,x), demo3(:,y), demo3(:,z),'g');
hold on;
plot3(expData(:,x), expData(:,y), expData(:, z), 'k')