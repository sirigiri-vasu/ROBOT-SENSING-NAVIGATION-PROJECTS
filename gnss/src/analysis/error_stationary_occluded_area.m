rosbag info 'stationary_berakhis.bag';
bagselect = rosbag("stationary_berakhis.bag");
bSel = select(bagselect,'Topic','/gps');
msgStructs = readMessages(bSel, 'DataFormat','struct');
msgStructs{1};
x = cellfun(@(m) double(m.UTMEasting),msgStructs);
y = cellfun(@(m) double(m.UTMNorthing),msgStructs);

accurate_value_x =[327710];
accurate_value_y =[4689300];

error_x = accurate_value_x - x
error_y = accurate_value_y - y
error = sqrt(error_x.^2 + error_y.^2)
mean_error = mean(error)
median_error = median(error)
hist(error)

grid on
hold on
title('error stationary occluded data error plot')
xlabel('range of error values')
ylabel('Frequency of errors')