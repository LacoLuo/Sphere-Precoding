clear all
rng("default")

%% Load simulation parameters
eval('sim_params');

%% Configuration paramters
K = params.K;                          % Number of users
numScenarios = params.numScenarios;    % Number of different user distributions
xBounds = params.xBounds;              % x-coordinate boundaries (meters)
yBounds = params.yBounds;              % y-coordinate boundaries (meters)
minDistance = params.minDistance;      % Minimum distance between users (meters)
userDistDir = 'user_distribution';       % Output directory

%% Check and create output directory if it doesn't exist
outputDir = fullfile('output', userDistDir);
if ~exist(outputDir, "dir")
    mkdir(outputDir);
end

%% Pre-allocate output array
UE_coords = zeros(numScenarios, K, 3);

%% Generate user coordinates
for i = 1:numScenarios
    coords = generateUserCoordinates(K, xBounds, yBounds, minDistance);
    UE_coords(i, :, :) = coords;
end

%% Save results
filename = fullfile(outputDir, sprintf('K_%d_x_%d_%d_y_%.1f_%.1f.mat', ...
    K, xBounds(1), xBounds(2), yBounds(1), yBounds(2)));
save(filename, 'UE_coords', '-v7.3');

%% Helper function to generate valid coordinates for one scenario
function coords = generateUserCoordinates(K, xBounds, yBounds, minDistance)
    coords = zeros(K, 3);
    for j = 1:K
        valid = false;
        while ~valid
            % Generate random coordinates
            x = xBounds(1) + (xBounds(2) - xBounds(1)) * rand;
            y = yBounds(1) + (yBounds(2) - yBounds(1)) * rand;
            newCoord = [x, y, 0];

            % Check distance to existing coordinates
            valid = true;
            for k = 1:j-1
                dist = norm(newCoord(1:2) - coords(k, 1:2));
                if dist < minDistance
                    valid = false;
                    break;
                end
            end

            if valid
                coords(j, :) = newCoord;
            end
        end
    end
end