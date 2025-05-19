clear all

%% Add paths
addpath(genpath('./')); 

%% Load simulation parameters
eval('sim_params');

%% Input and output directories setup
folder_name = sprintf('ant_%dx%d_h_%d_K_%d_v_%d_Nc_%d', ...
    params.N_v, params.N_h, params.BS_height, params.K, params.UE_velocity, params.N_c);
input_dir = fullfile('output', 'results', folder_name);
output_dir = input_dir;

%% Main processing
num_scenarios = 100 ;
num_steps = 10;

% Initialize merged results structure
merged_results_linear = initialize_results(num_steps);

% Merge results from the scenarios
for i = 1:num_scenarios
    load(fullfile(input_dir, sprintf("scenario_%d.mat", i)));
    merged_results_linear = merge_results(merged_results_linear, results_vary_mobility, num_steps);
end

% Convert merged results to dB scale
results_vary_mobility = convert_to_dB(merged_results_linear, num_steps, num_scenarios);

% Save final results
save(fullfile(output_dir, "results.mat"), ...
    "params", "results_vary_mobility", "-v7.3");

%% Helper functions
function results = initialize_results(num_steps)
    results = cell(1, num_steps + 1);
    types = {'UB', 'conj', 'dominant', 'ZF', 'equal_proj', 'sphere'};
    
    for step = 1:(num_steps + 1)
        for type = types
            results{step}.(['avg_SINR_linear_' type{1}]) = 0;
            results{step}.(['all_SINR_linear_' type{1}]) = {};
        end
    end
end

function merged_results = merge_results(merged_results, results, num_steps)
    types = {'UB', 'conj', 'dominant', 'ZF', 'equal_proj', 'sphere'};

    for step = 1:(num_steps + 1)
        for type = types
            % Accumulate average SINR (convert from dB to linear)
            merged_field = ['avg_SINR_linear_' type{1}];
            results_field = ['avg_SINR_dB_' type{1}];
            merged_results{step}.(merged_field) = ...
                merged_results{step}.(merged_field) + ...
                10^(results{step}.(results_field)/10);

            % Collect all SINR values
            merged_field = ['all_SINR_linear_' type{1}];
            results_field = ['all_SINR_dB_' type{1}];
            merged_results{step}.(merged_field){end + 1} = ...
                10.^(results{step}.(results_field)./10);
        end
    end
end

function results_dB = convert_to_dB(results_linear, num_steps, num_scenarios)
    results_dB = cell(1, num_steps + 1);
    types = {'UB', 'conj', 'dominant', 'ZF', 'equal_proj', 'sphere'};

    for step = 1:(num_steps + 1)
        for type = types
            % Convert average SINR to dB
            linear_field = ['avg_SINR_linear_' type{1}];
            dB_field = ['avg_SINR_dB_' type{1}];
            results_dB{step}.(dB_field) = ...
                10 * log10(results_linear{step}.(linear_field) / num_scenarios);

            % Convert all SINR values to dB
            linear_field = ['all_SINR_linear_', type{1}];
            dB_field = ['all_SINR_dB_', type{1}];
            results_dB{step}.(dB_field) = ...
                10 * log10(cat(2, results_linear{step}.(linear_field){:}));
        end
    end
end