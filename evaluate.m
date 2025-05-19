clear all
rng('default')

%% Add paths
addpath(genpath('./'));

%% Load simulation parameters
eval('sim_params');

%% System parameters
c = physconst('LightSpeed');        % Speed of light (m/s)
lambda = c / params.F_c;            % Wavelength (meter)
N_h = params.N_h;                   % Number of vertical elements
N_v = params.N_v;                   % Number of horizontal elements
BS_height = params.BS_height;       % Height of the base station (meter)
K = params.K;                       % Number of users
T_s = 1e-3;                         % Doppler-affected time interval (s)

%% Mobility parameters
V_KmH = params.UE_velocity;         % UE's speed in km/hr
V = V_KmH * 1e3 / 3600;             % UE's speed in m/s
time_step = params.time_step;       % ms
num_steps = params.num_steps;       % How many steps we will use in the simualtion
N_c = params.N_c;                   % Number of channel samples

%% One-sphere parameters
R_s = params.R_s;                   % Radius of one-sphere (m)
N_s = params.N_s;                   % Number of scatters

%% SNR and noise power
SNR_dB = 20; % dB
SNR_linear = 10^(SNR_dB / 10);
noise_power = 1 / SNR_linear;

%% Input and output directories setup
input_dir = fullfile('output', 'precoding_vectors', sprintf('ant_%dx%d_h_%d_K_%d_v_%d_Nc_%d', ...
    N_v, N_h, BS_height, K, V_KmH, N_c));
output_dir = fullfile('output', 'results', sprintf('ant_%dx%d_h_%d_K_%d_v_%d_Nc_%d', ...
    N_v, N_h, BS_height, K, V_KmH, N_c));
if ~exist(output_dir, "dir")
    mkdir(output_dir);
end

%% Evaluate the performance of each scenario
start_idx = 1;
end_idx = 100; 

for i = start_idx:end_idx
    tic
    fprintf('Scenario %d \n', i);

    % Load precoding vectors
    load(fullfile(input_dir, sprintf("scenario_%d.mat", i)));
    
    % Compute results with varying mobility
    results_vary_mobility = {};
    for j = 0:num_steps 
        % Compute the displacement due to mobility
        Delta_x = j * (time_step * 1e-3) * V; 

        % Generate the current user channel for evaluation
        % Note: The precoding vectors are designed based on the outdated channel information
        sample_coor_eval = generate_sample_coordinates(N_c, Delta_x, R_s, UE_coord);
        
        % Load precoding vectors
        dominant_F = precoding_methods{j+1}.dominant_F;
        equal_proj_F = precoding_methods{j+1}.equal_proj_F;
        sphere_F = precoding_methods{j+1}.sphere_F;

        % Compute SINR for each precoding method
        all_SINR_linear_UB = compute_SINR_upperbound(noise_power, Tx_coords, UE_coord, sample_coor_eval, lambda, N_s, R_s, T_s, V);
        all_SINR_linear_conj = compute_SINR(conj_F, noise_power, Tx_coords, UE_coord, sample_coor_eval, lambda, N_s, R_s, T_s, V);
        all_SINR_linear_ZF = compute_SINR(ZF_F, noise_power, Tx_coords, UE_coord, sample_coor_eval, lambda, N_s, R_s, T_s, V);
        all_SINR_linear_dominant = compute_SINR(dominant_F, noise_power, Tx_coords, UE_coord, sample_coor_eval, lambda, N_s, R_s, T_s, V);
        all_SINR_linear_equal_proj = compute_SINR(equal_proj_F, noise_power, Tx_coords, UE_coord, sample_coor_eval, lambda, N_s, R_s, T_s, V);
        all_SINR_linear_sphere = compute_SINR(sphere_F, noise_power, Tx_coords, UE_coord, sample_coor_eval, lambda, N_s, R_s, T_s, V);
        
        % Store average and all SINR values (in dB)
        results_vary_mobility{j+1}.avg_SINR_dB_UB = 10 .* log10(mean(all_SINR_linear_UB, 2));
        results_vary_mobility{j+1}.avg_SINR_dB_conj = 10 .* log10(mean(all_SINR_linear_conj, 2));
        results_vary_mobility{j+1}.avg_SINR_dB_ZF = 10 .* log10(mean(all_SINR_linear_ZF, 2));
        results_vary_mobility{j+1}.avg_SINR_dB_dominant = 10 .* log10(mean(all_SINR_linear_dominant, 2));
        results_vary_mobility{j+1}.avg_SINR_dB_equal_proj = 10 .* log10(mean(all_SINR_linear_equal_proj, 2));
        results_vary_mobility{j+1}.avg_SINR_dB_sphere = 10 .* log10(mean(all_SINR_linear_sphere, 2));
        
        results_vary_mobility{j+1}.all_SINR_dB_UB = 10 .* log10(all_SINR_linear_UB);
        results_vary_mobility{j+1}.all_SINR_dB_conj = 10 .* log10(all_SINR_linear_conj);
        results_vary_mobility{j+1}.all_SINR_dB_ZF = 10 .* log10(all_SINR_linear_ZF);
        results_vary_mobility{j+1}.all_SINR_dB_dominant = 10 .* log10(all_SINR_linear_dominant);
        results_vary_mobility{j+1}.all_SINR_dB_equal_proj = 10 .* log10(all_SINR_linear_equal_proj);
        results_vary_mobility{j+1}.all_SINR_dB_sphere = 10 .* log10(all_SINR_linear_sphere);
    end

    % Save results
    save(fullfile(output_dir, sprintf("scenario_%d.mat", i)), ...
        "params", "results_vary_mobility", "-v7.3");
    toc
end