function test_code_decode()
    s = [1, 2, 2, 3, 4, 5]
    val = index(s)
    
    val2 = decode(val)
end

function val = index(s)
    base = 5;
    s = fliplr(s);
    val = 0;
    for i = size(s, 2) :-1: 1
        val = val + (s(i)-1) * power(base, i-1);
    end    
    val = val + 1;
end

function x = decode(a)
    x = zeros(1, 6);
    a = a - 1;
    for i = 6 : -1 :1
        x(i) = mod(a, 5) + 1;
        a = fix(a/5);
    end

end

