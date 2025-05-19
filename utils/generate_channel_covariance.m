function [C] = generate_channel_covariance(lambda, Tx_coords, sample_coords, LoS_channel)
    N = size(Tx_coords, 1);
    K = size(sample_coords, 1);
    N_c = size(sample_coords, 2);

    C = zeros(K, N, N);
    batch_size = N_c;
    for i = 1:K
        C_k = zeros(N, N);
        for j = 0:batch_size:(N_c-batch_size)
            sample_coor_k = sample_coords(i, (j+1):(j+batch_size), :);
            sample_coor_k = repmat(reshape(sample_coor_k, batch_size, 1, 3), 1, N, 1); % [N_c, N, 3]
            distance = sqrt(sum((sample_coor_k - repmat(reshape(Tx_coords, 1, N, 3), batch_size, 1, 1)).^2, 3)); % [N_c, N]
            
            h = exp(- 1j * 2*pi / lambda .* distance);
    
            C_k_batch = reshape(h, batch_size, N, 1) .* conj(reshape(h, batch_size, 1, N)); % h * h'
            C_k_batch = squeeze(sum(C_k_batch, 1));
            C_k = C_k + C_k_batch;
        end
        C_k = C_k + (LoS_channel(:, i) * LoS_channel(:, i)');
        C(i, :, :) = C_k / (N_c+1);
    end
end