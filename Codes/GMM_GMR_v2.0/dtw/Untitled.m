for x=1:16
    figure;
    plot(demo1(:,x),'b');hold on; plot(demo2(:,x),'k');hold on;plot(demo3(:,x),'g');hold on; plot(data(:,x),'r')
end