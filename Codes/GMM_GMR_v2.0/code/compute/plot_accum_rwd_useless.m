function avg = plot_accum_rwd()
    s = 0;
    for i = 1 : 1
        [sol, Q, epi, accum] = rl();
        s = s + epi;
    end
    avg = s / 50;
    
    seg_t = 0;
    
    result = accum(2:end);
    for i = 2  : epi
        if result(i) - result(i-1) > 0.4
            seg_t = [seg_t i];
        end
    end
    
    seg = seg_t(2:end);
    seg
    
    for i = 1 : size(seg, 2)-1
       range = accum(seg(i) : seg(i+1));
       plot(range);
       hold on;
    end
    disp('end');
end