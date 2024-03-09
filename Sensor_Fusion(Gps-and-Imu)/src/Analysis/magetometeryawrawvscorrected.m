bag = rosbag("data_driving.bag");
topic = select(bag, 'Topic', '/imu');
msgs = readMessages(topic , 'DataFormat','struct');
msgs{1}.MagField;
mag_x = cellfun(@(i) double(i.MagField.MagneticField_.X),msgs);
mag_y = cellfun(@(i) double(i.MagField.MagneticField_.Y),msgs);
mag_z = cellfun(@(i) double(i.MagField.MagneticField_.Z),msgs);
time = cellfun(@(i) double(i.Imu.Header.Stamp.Sec),msgs);
time = time - time(1);
magRaw = [mag_x, mag_y, mag_z];
% Calculate the magnetometer bias
biasX = mean(mag_x);
biasY = mean(mag_y);
biasZ = mean(mag_z);

% Calculate the magnetometer scale factor
scaleX = max(mag_x) - min(mag_x);
scaleY = max(mag_y) - min(mag_y);
scaleZ = max(mag_z) - min(mag_z);

% Construct the magnetometer calibration matrix
magCalibration = diag([1/scaleX, 1/scaleY, 1/scaleZ]);
magCalibration(1, 4) = -biasX/scaleX;
magCalibration(2, 4) = -biasY/scaleY;
magCalibration(3, 4) = -biasZ/scaleZ;

magCorrected = magRaw * magCalibration;
yaw = atan2(magCorrected(:, 2), magCorrected(:, 1));
figure;
plot(time,yaw, 'b', 'LineWidth', 2);
hold on;
grid on;

plot(time,atan2(mag_y, mag_x), 'r', 'LineWidth', 2);
title('Estimation of Yaw for Magnetometer raw yaw vs corrected yaw')
legend('Corrected Yaw', 'Raw Yaw');
xlabel('time in seconds');
ylabel('Yaw Angle (rad)');

