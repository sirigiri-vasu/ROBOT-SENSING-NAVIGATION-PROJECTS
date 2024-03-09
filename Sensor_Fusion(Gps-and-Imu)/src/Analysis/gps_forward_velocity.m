% Load UTM coordinates and time from file
bag = rosbag("data_driving.bag");
topic1 = select(bag,'Topic','/gps');
msgs1 = readMessages(topic1, 'DataFormat','struct');
utm_east =cellfun(@(i) double(i.UTMEasting),msgs1);
utm_north = cellfun(@(i) double(i.UTMNorthing),msgs1);
utm_east = utm_east - utm_east(1);
utm_north = utm_north - utm_north(1);
utm_combine = [utm_east,utm_north];
%time = cellfun(@(i) double(i.Header.Stamp.Sec),msgs);
time = cellfun(@(i) double(i.Header.Stamp.Sec),msgs1);
time = time - time(1);

% Initialize variables
num_pts = size(utm_combine, 1) - 1; % number of velocity measurements
velocity_gps = zeros(num_pts, 1); % initialize array for velocity measurements

% Compute velocities
for i = 1:num_pts
    % Compute velocity between consecutive points
    if i < num_pts
        velocity_gps(i) = norm(utm_combine(i+1,:)-utm_combine(i,:))/(time(i+1)-time(i));
    end
end

% Plot velocity over time
figure;
plot(time(1:num_pts), velocity_gps,'r');
xlabel('Time (s)');
ylabel('Forward velocity (m/s)');
grid on;
title('GPS forward velocity vs time ')
