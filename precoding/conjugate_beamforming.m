function conj_F = conjugate_beamforming(channel)
    N = size(channel, 1);
    K = size(channel, 2);
    conj_F = zeros(N, K);
    for i = 1:K
        channel_k = channel(:, i);
        conj_F(:, i) = channel_k ./ vecnorm(channel_k);
    end
end