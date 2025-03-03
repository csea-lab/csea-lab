classdef SamplingLayer < nnet.layer.Layer
    methods
        function layer = SamplingLayer(name)
            layer.Name = name;
            layer.Description = 'Sampling Layer for VAE';
        end
        
        function Z = predict(~, X)
            mu = X(:, 1:end/2);
            sigma = exp(0.5 * X(:, end/2+1:end));
            epsilon = randn(size(mu));
            Z = mu + sigma .* epsilon;
        end
    end
end
