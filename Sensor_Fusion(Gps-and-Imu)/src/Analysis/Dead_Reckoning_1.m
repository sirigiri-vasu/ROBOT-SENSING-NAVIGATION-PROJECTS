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
x1 = cellfun(@(i) double(i.Imu.LinearAcceleration.X), imu_msgs);
y1 = cellfun(@(i) double(i.Imu.LinearAcceleration.Y), imu_msgs);
z1 = cellfun(@(i) double(i.Imu.LinearAcceleration.Z), imu_msgs);


%time1 = cellfun(@(i) double(i.Header.Stamp.Sec),imu_msgs);
sec = cellfun(@(i) double(i.Header.Stamp.Sec),imu_msgs);
nsec = cellfun(@(i) double(i.Header.Stamp.Nsec),imu_msgs);
time = sec + 10^(-9)
%time = cellfun(@(i) double(i.Header.Stamp.Sec),msgs1);
time = time - time(1);
%time1 = time1-time1(1);
gyroz = cellfun(@(i) double(i.Imu.Orientation.Z),imu_msgs);
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
plot(time, w_xd,'b','LineWidth',1);
grid on;
hold on;
plot(time,yddods_filt,'r','LineWidth',1);
legend('𝜔𝑋̇','𝑦̈𝑜𝑏𝑠')
xlabel('time (seconds)')
ylabel('acceleration (meter/second^2)')
title('𝜔𝑋̇ and 𝑦̈𝑜𝑏𝑠')
hold off;



