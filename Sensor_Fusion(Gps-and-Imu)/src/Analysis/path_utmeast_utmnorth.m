bag = rosbag("data_driving.bag");
topic1 = select(bag,'Topic','/gps');
msgs1 = readMessages(topic1, 'DataFormat','struct');
utm_east =cellfun(@(i) double(i.UTMEasting),msgs1);
utm_north = cellfun(@(i) double(i.UTMNorthing),msgs1);
utm_east = utm_east - utm_east(1);
utm_north = utm_north - utm_north(1);
plot(utm_east,utm_north);

grid on;
title('path estimated from the gps data')
xlabel('utm eating (meters)')
ylabel('utm northing (meters)')

