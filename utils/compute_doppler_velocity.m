function doppler_velocity = compute_doppler_velocity(speed_magnitude, speed_direction, projection_direction)
    % Check for zero vectors
    if norm(speed_direction) == 0
        error('Speed direction vector cannot be zero.');
    end
    if norm(projection_direction) == 0
        error('Projection direction vector cannot be zero.');
    end

    % Compute the speed vector
    % Normalize the speed direction vector
    speed_dir_magnitude = sqrt(sum(speed_direction.^2));
    unit_speed_dir = speed_direction / speed_dir_magnitude;
    % Scale by speed magnitude
    speed_vector = speed_magnitude * unit_speed_dir;
    vx = speed_vector(1); % x-component of speed
    vy = speed_vector(2); % y-component of speed
    vz = speed_vector(3); % z-component of speed

    % Compute projections onto projection direction vector
    % Magnitude squared of projection direction vector
    proj_dir_magnitude = sqrt(sum(projection_direction.^2));
    proj_dir_mag_sq = proj_dir_magnitude^2;

    % Scalar projection (radial velocity) of x-component [vx, 0, 0]
    dot_x = vx * projection_direction(1); % Dot product of [vx, 0, 0] and [dx, dy, dz]
    radial_x = dot_x / proj_dir_magnitude; % Scalar projection
    % Vector projection of x-component
    proj_x_coeff = dot_x / proj_dir_mag_sq;
    proj_x = proj_x_coeff * projection_direction; % Projected vector 

    % Scalar projection (radial velocity) of y-component [0, vy, 0]
    dot_y = vy * projection_direction(2); % Dot product of [0, vy, 0] and [dx, dy, dz]
    radial_y = dot_y / proj_dir_magnitude; % Scalar projection
    % Vector projection of y-component
    proj_y_coeff = dot_y / proj_dir_mag_sq;
    proj_y = proj_y_coeff * projection_direction; 

    % Scalar projection (radial velocity) of z-component [0, 0, vz]
    dot_z = vz * projection_direction(3); % Dot product of [0, 0, vz] and [dx, dy, dz]
    radial_z = dot_z / proj_dir_magnitude; % Scalar projection
    % Vector projection of z-component
    proj_z_coeff = dot_z / proj_dir_mag_sq;
    proj_z = proj_z_coeff * projection_direction;

    % Compute the doppler velocity
    doppler_velocity = radial_x + radial_y + radial_z;
end