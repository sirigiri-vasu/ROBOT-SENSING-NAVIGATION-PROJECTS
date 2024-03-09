rosbag info 'stationary_centennial.bag';
bagselect =rosbag('stationary_centennial.bag');
bsel = select(bagselect, 'Topic','/gps');
msgStructs = readMessages(bsel, 'DataFormat','struct');
msgStructs{1};
x= cellfun(@(m) double(m.UTMEasting),msgStructs);
y= cellfun(@(m) double(m.UTMNorthing),msgStructs);

accurate_value_x = x(end);
accurate_value_y = y(end);

error_x = accurate_value_x - x;
error_y = accurate_value_y - y;
error =sqrt(error_x.^2 + error_y.^2)
mean_error = mean(error)
median_error = median(error)

hist(error)
hold on
grid on
title('error stationary open area histogram')
xlabel('range of error values')
ylabel('Frequency of errors')