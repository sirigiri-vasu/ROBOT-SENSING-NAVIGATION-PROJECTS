rosbag info 'stationary_centennial.bag';
bagselect =rosbag('stationary_centennial.bag');
bsel = select(bagselect, 'Topic','/gps');
msgStructs = readMessages(bsel, 'DataFormat','struct');
msgStructs{1};
x= cellfun(@(m) double(m.UTMEasting),msgStructs);
y= cellfun(@(m) double(m.UTMNorthing),msgStructs);
z= cellfun(@(m) double(m.FixQuality),msgStructs);
colors = ['y', 'o', 'b', 'r'];


figure
hold on
for i = 2:5
    scatter(x(z == i-1), y(z == i-1), 10, colors(i-1), 'filled')
end


title('UTM Coordinates with Fix Quality Colored Points')
legend('Fix Quality 2', 'Fix Quality 3', 'Fix Quality 4', 'Fix Quality 5')
xlabel('UTMEasting values in meters')
ylabel('UTMNorthing values in meters')