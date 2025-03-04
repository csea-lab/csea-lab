classdef SamplingLayer < nnet.layer.Layer

    properties
        % No layer properties needed
    end

    methods
        function layer = SamplingLayer(name)
            % Constructor
            layer.Name = name;
            layer.Description = "Sampling Layer for VAE";
        end
        
        function Z = predict(layer, X)
            % Forward pass (reparameterization trick)
            % X(:, 1:D) -> Mean
            % X(:, D+1:2D) -> Log Variance
            D = size(X, 2) / 2; % Half the input size
            mu = X(:, 1:D);     % Mean
            logVar = X(:, D+1:2*D); % Log Variance

            % Sample random epsilon from standard normal distribution
            epsilon = randn(size(mu));

            % Reparameterization trick: Z = mu + epsilon .* exp(0.5 * logVar)
            Z = mu + epsilon .* exp(0.5 * logVar);
        end

        function [dLdX] = backward(layer, X, Z, dLdZ, ~)
            % Backpropagation
            D = size(X, 2) / 2;
            mu = X(:, 1:D);
            logVar = X(:, D+1:2*D);
            
            epsilon = (Z - mu) ./ exp(0.5 * logVar);

            % Derivatives w.r.t. input
            dLdMu = dLdZ; % Gradient for mean
            dLdLogVar = 0.5 * epsilon .* dLdZ; % Gradient for log variance

            % Combine gradients into one tensor
            dLdX = [dLdMu, dLdLogVar];
        end

        function layer = resetState(layer)
            % Nothing to reset (this is just for consistency)
        end
    end
end
