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
ant_spacing = params.ant_spacing;   % Spacing between antenna elements (percentage of wavelength)
BS_height = params.BS_height;       % Height of the base station (meter)
N = N_h * N_v;                      % Total antenna elements
K = params.K;                       % Number of users

%% Mobility parameters
V_KmH = params.UE_velocity;         % UE's speed in km/hr
V = V_KmH * 1e3 / 3600;             % UE's speed in m/s
time_step = params.time_step;       % ms
num_steps = params.num_steps;       % How many steps we will use in the simualtion
N_c = params.N_c;                   % Number of channel samples

%% One-sphere parameters
R_s = params.R_s;                   % Radius of one-sphere (m)

%% Output directory setup
output_dir = fullfile('output', 'precoding_vectors', sprintf('ant_%dx%d_h_%d_K_%d_v_%d_Nc_%d', ...
    N_v, N_h, BS_height, K, V_KmH, N_c));
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%% Generate antenna coordinates
[Tx_coords, D] = generate_Tx_coordinates(lambda, N_h, N_v, ant_spacing, BS_height);

%% Calculate Fraunhofer and Fresnel distances
Fraunhofer_d = 2 * D^2 / lambda;
Fresnel_d = 0.62 * sqrt(D^3 / lambda);

%% Load user distributions
user_dist_file = fullfile('output', 'user_distribution', sprintf('K_%d_x_%d_%d_y_%.1f_%.1f.mat', ...
    params.K, params.xBounds(1), params.xBounds(2), params.yBounds(1), params.yBounds(2)));
load(user_dist_file);
num_scenarios = params.numScenarios;
num_scenarios = 100;

%% Pre-allocate cell array for precoding methods
precoding_methods = cell(num_steps, 1);

%% Process each scenario
for i = 1:num_scenarios
    tic
    fprintf('Processing scenario %d/%d\n', i, num_scenarios);

    % Extract user coordinates for current scenario
    UE_coord = squeeze(UE_coords(i, :, :));

    % Generate LoS channel
    LoS_channel = generate_LoS_channel(lambda, Tx_coords, UE_coord);

    % Calculate conjugate beamforming and zero-forcing precoding
    conj_F = conjugate_beamforming(LoS_channel);
    ZF_F = zero_forcing(LoS_channel);

    % Process each time step
    for j = 0:num_steps
        fprintf('   Step %d/%d\n', j, num_steps);
        Delta_x = j * (time_step * 1e-3) * V; % Displacement (meters)

        % Generate one-sphere channel covariance
        sample_coords = generate_sample_coordinates(N_c, Delta_x, R_s, UE_coord);
        C = generate_channel_covariance(lambda, Tx_coords, sample_coords, LoS_channel);

        % Calculate precoding vectors
        dominant_F = dominant_eigenvector_beamforming(N, K, C);
        equal_proj_F = equal_projection(N, K, C);
        sphere_F = sphere_precoding(N, K, C);

        % Store results
        precoding_methods{j+1} = struct(...
            'dominant_F', dominant_F, ...
            'equal_proj_F', equal_proj_F, ...
            'sphere_F', sphere_F);
    end

    % Save results for current scenario
    filename = fullfile(output_dir, sprintf('scenario_%d.mat', i));
    save(filename, 'params', ...
        'Tx_coords', 'UE_coord', ...
        'conj_F', 'ZF_F', ...
        'precoding_methods', '-v7.3');

    fprintf('Scenario %d completed in %.2f seconds\n', i, toc);
end












