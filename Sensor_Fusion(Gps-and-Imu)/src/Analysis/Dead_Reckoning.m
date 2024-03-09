bag = rosbag("data_driving.bag");
topic1 = select(bag,'Topic','/gps');
msgs1 = readMessages(topic1, 'DataFormat','struct');
utm_east =cellfun(@(i) double(i.UTMEasting),msgs1);
utm_north = cellfun(@(i) double(i.UTMNorthing),msgs1);
utm_east = utm_east - utm_east(1);
utm_north = utm_north - utm_north(1);
utm_combine = [utm_east,utm_north];
imu_topic = select(bag,'Topic','/imu');
imu_msgs = readMessages(imu_topic, 'DataFormat','struct');
x = cellfun(@(i) double(i.Imu.LinearAcceleration.X), imu_msgs);
y = cellfun(@(i) double(i.Imu.LinearAcceleration.Y), imu_msgs);
z = cellfun(@(i) double(i.Imu.LinearAcceleration.Z), imu_msgs);
time1 = cellfun(@(i) double(i.Header.Stamp.Sec),imu_msgs);
time = cellfun(@(i) double(i.Header.Stamp.Sec),msgs1);
time = time - time(1);
time1 = time1-time1(1);
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

plot(time1,x,'b');
hold on;
plot(time(1:num_pts), velocity_gps,'r');
title('velocity estimate from IMU & GPS after adjustment')
xlabel("time in seconds")
ylabel('velocity( meter/second')
legend('velocity imu','velocity gps')
grid on;
