clear all

%% Add paths
addpath(genpath('./'));

%% Load simulation parameters
eval('sim_params');

%% Load precoding vectors
scenario_idx = 4;
folder_name = sprintf('ant_%dx%d_h_%d_K_%d_v_%d_Nc_%d', ...
    params.N_v, params.N_h, params.BS_height, params.K, params.UE_velocity, params.N_c);
input_dir = fullfile("output", "precoding_vectors", folder_name);
load(fullfile(input_dir, sprintf("scenario_%d.mat", scenario_idx)));

%% Specify the user to be evaluated
observed_UE = 2;
step = 2;

V = params.UE_velocity * 1e3 / 3600;
radius_of_sphere = params.R_s + step * (params.time_step * 1e-3) * V;

%% Specify the precoding method
Conj = 0;
ZF = 1;
Dominant = 0;
Equal_proj = 0;
Sphere = 1;

%% Define the area of interest
x_min = 0;
x_max = 10;
y_min = -5;
y_max = 5;
res = 0.05;

N = params.N_v * params.N_h;
K = params.K;
lambda = physconst('LightSpeed') / params.F_c; % Wavelength (meter)
[A, ~] = generate_dictionary(N, Tx_coords, lambda, x_min, res, x_max, y_min, res, y_max);

%% Plot Settings
set(0,'defaultLineLineWidth', 3)
set(0,'defaultAxesFontSize',22)
set(0,'defaultAxesFontName','Arial')
set(0,'defaultAxesLineWidth', 1)
figure_size = 660;
figure_x = figure_size*(1+sqrt(5)) / (5);
figure_y = figure_size / 2;
pixel = get(0,'screensize');
middle_x = pixel(3)/2;
middle_y = pixel(4)/2;
set(0,'defaultFigurePosition', [middle_x-figure_x middle_y-figure_y figure_x*2 figure_y*2]);
set(groot,'DefaultAxesColororder', 'default');
clear figure_size figure_x figure_y pixel middle_x middle_y

%% Plot beamforming gain
if Conj
    F = conj_F(:, observed_UE);
    plot(F, A, K, observed_UE, UE_coord, res, x_min, x_max, y_min, y_max, radius_of_sphere, "Conjugate Beamforming")
end
if ZF
    F = ZF_F(:, observed_UE);
    plot(F, A, K, observed_UE, UE_coord, res, x_min, x_max, y_min, y_max, radius_of_sphere, "Zero-forcing Precoding")
end
if Dominant
    F = precoding_methods{step}.dominant_F(:, observed_UE);
    plot(F, A, K, observed_UE, UE_coord, res, x_min, x_max, y_min, y_max, radius_of_sphere, "Dominant Eigenvector")
end
if Equal_proj
    F = precoding_methods{step}.equal_proj_F(:, observed_UE);
    plot(F, A, K, observed_UE, UE_coord, res, x_min, x_max, y_min, y_max, radius_of_sphere, "Equal Projection")
end
if Sphere
    F = precoding_methods{step}.sphere_F(:, observed_UE);
    plot(F, A, K, observed_UE, UE_coord, res, x_min, x_max, y_min, y_max, radius_of_sphere, "Sphere Precoding")
end

%% Helper function
function plot(F, A, K, observed_UE, UE_coord, res, x_min, x_max, y_min, y_max, radius_of_sphere, fig_title)
    bf_gain = A' * F;
    bf_gain = 10 .* log10(abs(bf_gain).^2);
    bf_gain = reshape(bf_gain, [(x_max-x_min)/res+1, (y_max-y_min)/res+1]).';
    bf_gain = flip(bf_gain, 1);
    
    figure()
    imagesc(bf_gain);
    for i = 1:K
        if i == observed_UE
            rectangle('Position', [(UE_coord(i, 1)/res - 4), ((-UE_coord(i, 2)+5)/res - 4), 10, 10], 'EdgeColor', 'r', LineWidth=2)
        else
            rectangle('Position', [(UE_coord(i, 1)/res - 4), ((-UE_coord(i, 2)+5)/res - 4), 10, 10], 'EdgeColor', 'black', LineWidth=2)
        end
    end
    grid off
    
    set(gca, 'FontName', 'Times New Roman');
    set(findall(gcf, '-property', 'FontName'), 'FontName', 'Times New Roman');
    xt = get(gca, 'XTick');                                          
    xtlbl = linspace(x_min + (x_max - x_min)/numel(xt), x_max, numel(xt));  
    yt = get(gca, 'YTick');                                          
    ytlbl = linspace(y_max - (y_max - y_min)/numel(yt), y_min, numel(yt));  
    set(gca, 'XTick', xt, 'XTickLabel', xtlbl , 'YTick', yt, 'YTickLabel', ytlbl)
    ylabel('Y-Axis (Meter)')
    xlabel('X-Axis (Meter)');
    colorbar
end