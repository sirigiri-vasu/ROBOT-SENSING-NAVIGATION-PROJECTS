bag = rosbag("data_driving.bag");


% Extract linear acceleration data
imu_topic = select(bag,'Topic','/imu');
imu_msgs = readMessages(imu_topic, 'DataFormat','struct');
x = cellfun(@(i) double(i.Imu.LinearAcceleration.X), imu_msgs);
y = cellfun(@(i) double(i.Imu.LinearAcceleration.Y), imu_msgs);
z = cellfun(@(i) double(i.Imu.LinearAcceleration.Z), imu_msgs);
time = cellfun(@(i) double(i.Header.Stamp.Sec),imu_msgs);

time = time - time(1);

plot(time,x);
title('imu forward velocity vs time')
xlabel('Time (s)');
ylabel('Forward velocity (m/s)');
grid on;
