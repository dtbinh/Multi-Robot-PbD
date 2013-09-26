function test_fk(input)

hand = input(1:6);
joint = input(7:end-3);

[result1, result2] = ForwardKinematics(joint);

hand(1:3) = hand(1:3) * 1000;
error = result2 - hand';
error

end