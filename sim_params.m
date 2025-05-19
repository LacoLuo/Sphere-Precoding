% System parameters
params.N_v = 16;           % Number of vertical elements
params.N_h = 64;           % Number of horizontal elements
params.ant_spacing = 0.5;  % Spacing between antenna elements (percentage of wavelength)
params.BS_height = 3;      % Height of the base station (meter)
params.F_c = 28e9;         % Carrier frequency (Hz)

% User distribution parameters
params.K = 5;                    % Number of users
params.numScenarios = 100;       % Number of different user distributions
params.xBounds = [5, 10];        % x-coordinate boundaries (meters)
params.yBounds = [-2.5, 2.5];    % y-coordinate boundaries (meters)
params.minDistance = 0.5;        % Minimum distance between users (meters)

% Mobility
params.UE_velocity = 20;   % km/hr
params.time_step = 5;      % ms
params.num_steps = 10;     % How many steps we will use in the simualtion
params.N_c = 100;          % Number of channel samples
params.dict_res = 0.025;   % Distance between grid points (m)

% One-sphere
params.R_s = 0.1;          % Radius of one-sphere (m)
params.N_s = 10;           % Number of scatters