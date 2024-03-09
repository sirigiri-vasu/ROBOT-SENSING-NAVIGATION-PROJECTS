clear all
bag = rosbag("data_driving.bag");
topic = select(bag, 'Topic', '/imu');
msgs = readMessages(topic , 'DataFormat','struct');
msgs{1}.Imu.Orientation;
ox = cellfun(@(i) double(i.Imu.Orientation.X),msgs);
oy = cellfun(@(i) double(i.Imu.Orientation.Y),msgs);
oz = cellfun(@(i) double(i.Imu.Orientation.Z),msgs);
ow = cellfun(@(i) double(i.Imu.Orientation.W),msgs);
time1 = cellfun(@(i) double(i.Header.Stamp.Sec),msgs);
mag_x = cellfun(@(i) double(i.MagField.MagneticField_.X),msgs);
mag_y = cellfun(@(i) double(i.MagField.MagneticField_.Y),msgs);
mag_z = cellfun(@(i) double(i.MagField.MagneticField_.Z),msgs);
time1 = time1 - time1(1);
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
%figure;
%plot(time,yaw, 'b', 'LineWidth', 1);
%hold on;
%grid on;


%plot(time,Z, 'k', 'LineWidth', 1);
%title('Estimation  for Magnetometer corrected yaw vs gyro integrated yaw with respect to time')
%legend('Corrected Yaw','integrated gyro yaw');
%xlabel('time in seconds');
%ylabel('Yaw Angle (rad)');
%low pass filtering of magnetometer imu----------------------------------
lowpass = lowpass(unwrap(yaw),0.0001,40);
figure(4)
plot(time1,unwrap(lowpass),'r','LineWidth',2)
hold on;
grid on;

%high pass filtering of gyro imu------------------------------------
highpass = highpass(unwrap(Z),0.07,40);

plot(time1, unwrap(highpass),'b','LineWidth',2)

% adding some complementary filter to the plots
filter_yaw = lowpass + highpass;

plot(time1,unwrap(filter_yaw),'k',"LineWidth",1)

legend('lowpass filter mag_yaw','highpass filter Gyro_yaw','Complementary filter yaw')
title("lowpass filter Mag yaw,highpass filter gyro yaw,complementary filter for yaw")
xlabel("time in seconds")
ylabel('yaw in radians')