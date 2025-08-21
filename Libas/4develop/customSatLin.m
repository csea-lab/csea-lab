classdef customSatLin < nnet.layer.Layer
    methods
        function layer = customSatLin(name)
            layer.Name = name;
        end
        function Z = predict(~, X)
            Z = min(max(X, 0), 1);
        end
    end
end
