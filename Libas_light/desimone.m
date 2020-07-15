% desimone
function [output] = desimone()


bias = 5; 
weight_exc = [0.8 0.9]
weight_inh = [0.2 0.9]

y_input1 = [10 10]

bias = [5 1]



for i = 1:2
    
    y12excit = sum(weight_exc(i)*y_input1(i)*bias(i))

    y12inhib = sum(weight_inh(i)*y_input1(i)*bias(i))
end


gamma = 0.1
beta = 1
alpha = 0.2

y12(1) = y12excit + y12inhib; 

for t = 1:30

    y12(t+1) = y12(t) + gamma*( (beta-y12(t))*y12excit - (alpha + y12inhib)*y12(t));

end

output = y12;
