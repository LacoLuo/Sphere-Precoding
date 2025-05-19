function [dominant_F] = dominant_eigenvector_beamforming(N, K, C)
    dominant_F = zeros(N, K);
    for i = 1:K
        C_k = squeeze(C(i, :, :));
        [U_k, S_k, ~] = svd(C_k);
        precoding_vector = U_k(:, 1);
        dominant_F(:, i) = precoding_vector ./ vecnorm(precoding_vector);
    end
end