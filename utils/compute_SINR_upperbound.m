function [SINR_linear] = compute_SINR_upperbound(noise_power, Tx_coords, UE_coord, sample_coors, lambda, N_s, R_s, T_s, V)
    K = size(sample_coors, 1);   % Number of total users
    N_c = size(sample_coors, 2); % Number of sampling positions for each user

    SINR_linear = zeros(K, N_c);
    for i=1:K
        sample_coors_k = squeeze(sample_coors(i, :, :));
        for c = 1:N_c
            % Extract the sampling coordinate of the k-th user
            sample_coor_k = sample_coors_k(c, :);

            % Generate the scatter coordiantes around the user
            [scatter_coors, r_s] = generate_scatter_coordinates(N_s, R_s, sample_coor_k);
            
            channel = {};
            speed_direction = sample_coor_k - UE_coord(i, :);
            % Compute the LoS channel
            projection_direction = sample_coor_k - Tx_coords;
            LoS_distance = sqrt(sum((Tx_coords - sample_coor_k).^2, 2));
            doppler_velocity = zeros(size(projection_direction, 1), 1);
            for v = 1:size(projection_direction, 1)
                doppler_velocity(v) = compute_doppler_velocity(V, speed_direction, projection_direction(v, :));
            end
            channel{end+1} = exp(- 1j * 2*pi / lambda .* LoS_distance) .* ...
                exp(- 1j * 2*pi / lambda * T_s .* doppler_velocity);
            % Compute the NLoS channels
            for s = 1:N_s
                scatter_coor = scatter_coors(s, :);
                distance = sqrt(sum((Tx_coords - scatter_coor).^2, 2));
                projection_direction = sample_coor_k - scatter_coor;
                doppler_velocity = compute_doppler_velocity(V, speed_direction, projection_direction);
                channel{end+1} = exp(- 1j * 2*pi / lambda .* distance) .* exp(- 1j * 2*pi / lambda * r_s) .* ...
                    exp(- 1j * 2*pi / lambda * T_s * doppler_velocity);
            end
            channel = cat(2, channel{:});
            channel = sum(channel, 2);
            
            % Compute the received signal power
            precoding_vector = channel ./ vecnorm(channel);
            signal_power = channel' * precoding_vector;
            signal_power = abs(signal_power).^2;
            
            % For the upper bound, we assume there's no inter-user interference
            interference_power = 0;
            SINR_linear(i, c) = signal_power ./ (noise_power + interference_power);
        end
    end
    SINR_linear = reshape(SINR_linear, 1, K*N_c);
end