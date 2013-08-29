function y = test_add(x)
    y(1) = x(1) + x(2);
    y(2) = test_minus(x);
end