clear all

%% Add paths
addpath(genpath('./')); 

%% Load simulation parameters
eval('sim_params');

%% System parameters
N_h = params.N_h;                   % Number of vertical elements
N_v = params.N_v;                   % Number of horizontal elements
BS_height = params.BS_height;       % Height of the base station (meter)
K = params.K;                       % Number of users

%% Mobility parameters
V_KmH = params.UE_velocity;         % UE's speed in km/hr
V = V_KmH * 1e3 / 3600;             % UE's speed in m/s
time_step = params.time_step;       % ms
num_steps = params.num_steps;       % How many steps we will use in the simualtion
N_c = params.N_c;                   % Number of channel samples

%% Input directory setup
folder_name = sprintf('ant_%dx%d_h_%d_K_%d_v_%d_Nc_%d', ...
    N_v, N_h, BS_height, K, V_KmH, N_c);
input_dir = fullfile("output", "results", folder_name);
load(fullfile(input_dir, "results.mat"));

%% Plot the average SINR
% Extract average SINR data for all methods
data = zeros(num_steps + 1, 6);
methods = {'UB', 'sphere', 'ZF', 'dominant', 'conj', 'equal_proj'};

for step = 1:(num_steps + 1)
    for m = 1:length(methods)
        field = ['avg_SINR_dB_' methods{m}];
        data(step, m) = results_vary_mobility{step}.(field)(1);
    end
end

set_default_plot;

x = 0:num_steps;
x = x .* (time_step * 1e-3) * V;

figure()

plot(x, data(:, 1), '--', DisplayName='Upperbound (Single User)', Color='black')
hold on
plot(x, data(:, 2), marker='o', MarkerFaceColor='white', DisplayName='Sphere Precoding', Color='#921D21')
hold on
plot(x, data(:, 3), marker='o', MarkerFaceColor='white', DisplayName='Zero-Forcing Precoding', Color='#464145')
hold on
plot(x, data(:, 4), ':', marker='o', MarkerFaceColor='white', DisplayName='Dominant Eigenvector', Color='#0096A2')
hold on
plot(x, data(:, 5), ':', marker='o', MarkerFaceColor='white', DisplayName='Conjugate Beamforming ', Color='#464145')
hold on
plot(x, data(:, 6), ':', marker='o', MarkerFaceColor='white', DisplayName='Equal Projection', Color='#921D21')

grid on
box on

set(gca, 'FontName', 'Times New Roman');
set(findall(gcf, '-property', 'FontName'), 'FontName', 'Times New Roman');
set(gca, 'LooseInset', get(gca, 'TightInset'));
ylabel('Average SINR (dB)')
xlabel('Moving distance (meter)');
xlim([0, x(num_steps+1)]);
legend('Location', 'southwest')

%% Plot the CDF of SINR
step = floor(num_steps/2)+1;
UE_mobility = floor(num_steps/2) * (time_step * 1e-3) * V;

% Extract SINR data for CDF plotting
data = cell(1, length(methods));
method = {'UB', 'sphere', 'ZF', 'dominant', 'conj', 'equal_proj'};
for m = 1:length(methods)
    field = ['all_SINR_dB_' methods{m}];
    data{m} = results_vary_mobility{step}.(field);
end

figure();

[f, x] = ecdf(data{1});
plot(x, f, '--', DisplayName='Upperbound (Single User)', Color='black')
hold on
[f, x] = ecdf(data{2});
plot(x, f, DisplayName='Sphere Precoding', Color='#921D21')
hold on
[f, x] = ecdf(data{3});
plot(x, f, DisplayName='Zero-Forcing Precoding', Color='#464145')
hold on
[f, x] = ecdf(data{4});
plot(x, f, ':', DisplayName='Dominant Eigenvector', Color='#0096A2')
hold on
[f, x] = ecdf(data{5});
plot(x, f, ':', DisplayName='Conjugate Beamforming', Color='#464145')
hold on
[f, x] = ecdf(data{6});
plot(x, f, ':', DisplayName='Equal Projection', Color='#921D21')
hold on

grid on
box on

set(gca, 'FontName', 'Times New Roman');
set(findall(gcf, '-property', 'FontName'), 'FontName', 'Times New Roman');
set(gca, 'LooseInset', get(gca, 'TightInset'));
xlabel('SINR (dB)')
ylabel('CDF')
legend('Location', "northwest")