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
x1 = cellfun(@(i) double(i.Imu.LinearAcceleration.X), msgs);
y1 = cellfun(@(i) double(i.Imu.LinearAcceleration.Y), msgs);
z1 = cellfun(@(i) double(i.Imu.LinearAcceleration.Z), msgs);
sec = cellfun(@(i) double(i.Header.Stamp.Sec),msgs);
nsec = cellfun(@(i) double(i.Header.Stamp.Nsec),msgs);
time1 = sec + 10^(-9)
time1 = time1 - time(1);
topic1 = select(bag,'Topic','/gps');
msgs1 = readMessages(topic1, 'DataFormat','struct');
utm_east =cellfun(@(i) double(i.UTMEasting),msgs1);
utm_north = cellfun(@(i) double(i.UTMNorthing),msgs1);
utm_east = utm_east - utm_east(1);
utm_north = utm_north - utm_north(1);
utm_combine = [utm_east,utm_north];
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
plot(time,unwrap(lowpass),'r','LineWidth',2)
hold on;
grid on;

%high pass filtering of gyro imu------------------------------------
highpass = highpass(unwrap(Z),0.07,40);

%plot(time, unwrap(highpass),'b','LineWidth',2)

% adding some complementary filter to the plots
filter_yaw = lowpass + highpass;
gyroz = cellfun(@(i) double(i.Imu.Orientation.Z),msgs);
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

%plot(time1,x,'b');
%hold on;
%plot(time(1:num_pts), velocity_gps,'r');
%title('velocity estimate from IMU & GPS after adjustment')
%xlabel("time in seconds")
%ylabel('velocity( meter/second')
%legend('velocity imu','velocity gps')
%grid on;
%hold off;

dias_pos = [0,1655,3796,4954,8218,9048,17282];
accx_corrected = zeros(size(x1));
for i = 1:length(dias_pos)
    if i==length(dias_pos)-1
        mean_dias = mean(x1(dias_pos(1,i):dias_pos(1,i+1)));
        accx_corrected(dias_pos(1,i):dias_pos(1,i+1)) = x1(dias_pos(1,i):dias_pos(1,i+1)) - mean_dias; 
        break
    end
    if i == 1
        mean_dias = mean(x1(1:dias_pos(1,2)));
        accx_corrected(1:dias_pos(1,3)) = x1(1:dias_pos(1,3))-mean_dias;
    else 
        mean_dias = mean(x1(dias_pos(1,i):dias_pos(1,i+1)));
        accx_corrected(dias_pos(1,i):dias_pos(1,i+2)) = x1(dias_pos(1,i):dias_pos(1,i+2))-mean_dias;
    end
end

velocity_imu_corr = cumtrapz(accx_corrected*(1/40));



x_dd_ods = accx_corrected;
x_d = velocity_imu_corr;
w_xd = gyroz.*x_d;

y_dd_ods = y1 + w_xd;

xddods_filt = lowpass(x_dd_ods,0.001,40);
yddods_filt = lowpass(y_dd_ods,0.001,40);

figure(8)
plot(time1, w_xd,'b','LineWidth',1);
grid on;
hold on;
plot(time1,yddods_filt,'r','LineWidth',1);
legend('𝜔𝑋̇','𝑦̈𝑜𝑏𝑠')
xlabel('time (seconds)')
ylabel('acceleration (meter/second^2)')
title('𝜔𝑋̇ and 𝑦̈𝑜𝑏𝑠')
hold off;


%plot(time,unwrap(filter_yaw),'k',"LineWidth",1)

%legend('lowpass filter mag_yaw','highpass filter Gyro_yaw','Complementary filter yaw')
%title("lowpass filter Mag yaw,highpass filter gyro yaw,complementary filter for yaw")
%xlabel("time in seconds")
%ylabel('yaw in radians')
