bag = rosbag("data_going_in_circles.bag");
topic = select(bag, 'Topic', '/imu');
msgs = readMessages(topic , 'DataFormat','struct');
msgs{1}.MagField;
x = cellfun(@(i) double(i.MagField.MagneticField_.X),msgs);
y = cellfun(@(i) double(i.MagField.MagneticField_.Y),msgs);
z = cellfun(@(i) double(i.MagField.MagneticField_.Z),msgs);

mag = [x,y,z];

bias = mean(mag);
mag_hard = mag - bias;

% Soft iron calibration
A = diag(range(mag_hard));
mag_calibrated = mag_hard / A;

% Plot the magnetometer measurements after hard and soft iron calibration
figure;
plot3(mag_hard(:,1), mag_hard(:,2), mag_hard(:,3), '.', 'Color', [0.5 0.5 0.5]);
hold on;
plot(mag_calibrated(:,1), mag_calibrated(:,2));
xlabel('X');
ylabel('Y');

title('Magnetometer measurements after calibration');
grid on;
xlabel('Magnetic field x')
ylabel('Magnetic filed y')
axis equal;
legend('Hard iron calibration', 'soft iron calibration');
view(0,90);