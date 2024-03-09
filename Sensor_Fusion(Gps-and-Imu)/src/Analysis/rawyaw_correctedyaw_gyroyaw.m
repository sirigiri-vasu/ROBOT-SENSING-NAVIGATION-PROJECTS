clear all
bag = rosbag("data_driving.bag");
topic = select(bag, 'Topic', '/imu');
msgs = readMessages(topic , 'DataFormat','struct');
msgs{1}.Imu.Orientation;
ox = cellfun(@(i) double(i.Imu.Orientation.X),msgs);
oy = cellfun(@(i) double(i.Imu.Orientation.Y),msgs);
oz = cellfun(@(i) double(i.Imu.Orientation.Z),msgs);
ow = cellfun(@(i) double(i.Imu.Orientation.W),msgs);
time = cellfun(@(i) double(i.Header.Stamp.Sec),msgs);
mag_x = cellfun(@(i) double(i.MagField.MagneticField_.X),msgs);
mag_y = cellfun(@(i) double(i.MagField.MagneticField_.Y),msgs);
mag_z = cellfun(@(i) double(i.MagField.MagneticField_.Z),msgs);
time = time - time(1);
qt = [ow,ox,oy,oz];
eulXYZ = quat2eul(qt, "XYZ");
%eulXYZ = rad2deg(eulXYZ);
X = eulXYZ(:,1);
Y = eulXYZ(:,2);
Z = eulXYZ(:,3);
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
plot(time,yaw, 'b', 'LineWidth', 1);
hold on;
grid on;

plot(time,atan2(mag_y, mag_x), 'r', 'LineWidth', 1);
plot(time,Z, 'k', 'LineWidth', 1);
title('Estimation of Yaw for Magnetometer raw yaw vs corrected yaw vs gyro integrated yaw with respect to time')
legend('Corrected Yaw', 'Raw Yaw','integrated gyro yaw');
xlabel('time in seconds');
ylabel('Yaw Angle (rad)');

%plot(time,Z, 'k', 'LineWidth', 1);
%grid on;
%title('Yaw integrated from Gyro')
%xlabel('time in seconds')
%ylabel('yaw(radians)')
%legend('Gyroscope integrated yaw')
