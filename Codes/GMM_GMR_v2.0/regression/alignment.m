    % Read raw Data in Time*Dim format
function alignment(numDemo)
  
    x = 9;
    y = 10;
    z = 11;
  
    %% plot raw data
    for i = 1 : numDemo
        filename = ['raw_', num2str(i),'.mat'];
        load(filename);
    end
    %plot raw 3D trajectory of end-effector
    figure;
    plot3(raw_1(:,x), raw_1(:,y), raw_1(:,z), 'r');
    hold on;
    plot3(raw_2(:,x), raw_2(:,y), raw_2(:,z), 'b');
    hold on;
    plot3(raw_3(:,x), raw_3(:,y), raw_3(:,z), 'g');
    hold on;
    plot3(raw_4(:,x), raw_4(:,y), raw_4(:,z), 'k');
    hold on;
    plot3(raw_5(:,x), raw_5(:,y), raw_5(:,z), 'Color', [0.5 0 0.5]);
    grid on;
    xlabel('x','fontsize',16); ylabel('y' ,'fontsize',16); zlabel('z','fontsize',16); 
    title('Original 3D', 'FontSize', 16);

    %  plot raw 2D trajector of end-effector  
    figure; 
    camroll(90);
    plot(raw_1(:,x), raw_1(:,y), 'r-');
    hold on;
    plot(raw_2(:,x), raw_2(:,y), 'b-');
    hold on;
    plot(raw_3(:,x), raw_3(:,y), 'g-'); hold on;
    hold on;
    plot(raw_4(:,x), raw_4(:,y), 'k-'); hold on;
    hold on;
    plot(raw_5(:,x), raw_5(:,y), '-','Color', [0.5 0 0.5]); hold on;
    grid on;
    xlabel('x','fontsize',16); ylabel('y' ,'fontsize',16);
    title('Original 2D', 'FontSize', 16);

    %% Alignment
    % select reference demo
    demo_ref = raw_1;
    [Time, Dimension] = size(demo_ref);
    name_align = 'align_';
    align_1 = raw_1;
    
    % align all demos to reference demo
    Data = demo_ref;
    for i = 2:numDemo
        input = ['raw_', num2str(i)];
        fprintf('Aligning %s\n', input);
        %[w,new] = dtwMD(readRaw(strcat(strcat(path, 'demo_'), num2str(i))),demo_ref);
        [w,output] = eval(['dtwMD(',input, ',demo_ref)']); 
        eval([name_align num2str(i), '= output;']);
        Data = [Data; output];
        %plot(output(:,y), output(:,z),'*'); hold on;
        %figure; plot(demo(dim,:),'k*-'); hold on; plot(demo2(dim,:),'b.-'); hold on;plot(new,'ro-');
    end

    %% Plot aligned trajectory
    %plot aligned 2D trajectory of end-effector
    figure;
    plot(align_1(:,x), align_1(:,y), 'r');
    hold on;
    plot(align_2(:,x), align_2(:,y), 'b');
    hold on;
    plot(align_3(:,x), align_3(:,y), 'g');
    hold on;
    plot(align_4(:,x), align_4(:,y), 'k');
    hold on;
    plot(align_5(:,x), align_5(:,y), 'Color', [0.5 0 0.5]);
    grid on;
    xlabel('y','fontsize',16); ylabel('z' ,'fontsize',16);
    title('Aligned 2D', 'FontSize', 16);

    %plot aligned 3D trajectory of end-effector
    figure; 
    plot3(align_1(:,x), align_1(:,y), align_1(:,z), 'r');
    hold on;
    plot3(align_2(:,x), align_2(:,y), align_2(:,z), 'k');
    hold on;
    plot3(align_3(:,x), align_3(:,y), align_3(:,z), 'b');
    hold on;
    plot3(align_4(:,x), align_4(:,y), align_4(:,z), 'k');
    hold on;
    plot3(align_5(:,x), align_5(:,y), align_5(:,z), 'Color', [0.5 0 0.5]);
    grid on;
    xlabel('x','fontsize',16); ylabel('y' ,'fontsize',16); zlabel('z','fontsize',16);

    
    
    %% save
    %Transpose to Dim * Tim for GMR
    Data = Data';
    time = repmat([1:Time],1,numDemo);
    Data = [time;Data];
    aligned = Data;
    save('aligned.mat', 'aligned');
  
   
end