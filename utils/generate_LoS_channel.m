function [LoS_channel] = generate_LoS_channel(lambda, Tx_coords, UE_coord)
    N = size(Tx_coords, 1);
    K = size(UE_coord, 1);
    LoS_propagation_distance = zeros(N, K);
    for i=1:K
        LoS_propagation_distance(:, i) = sqrt(sum((Tx_coords - UE_coord(i, :)).^2, 2));
    end
    LoS_channel = exp(- 1j * 2*pi / lambda .* LoS_propagation_distance);
end