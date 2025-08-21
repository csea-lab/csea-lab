classdef customPureLin < nnet.layer.Layer
    methods
        function layer = customPureLin(name)
            layer.Name = name;
        end
        function Z = predict(~, X)
            Z = X;
        end
    end
end
