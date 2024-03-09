rosbag info 'stationary_berakhis.bag';
bagselect = rosbag("stationary_berakhis.bag");
bSel = select(bagselect,'Topic','/gps');
msgStructs = readMessages(bSel, 'DataFormat','struct');
msgStructs{1};
x = cellfun(@(m) double(m.UTMEasting),msgStructs);
y = cellfun(@(m) double(m.UTMNorthing),msgStructs);
z = cellfun(@(m) double(m.FixQuality),msgStructs);

colors = ['y', 'o', 'b', 'r'];

figure
grid on
hold on
for i = 2:5
    scatter(x(z == i-1), y(z == i-1), 10, colors(i-1), 'filled')
end
plot(x,y)


title('stationary data(occluded area) with fix quality colored points')
legend('Fix Quality 2', 'Fix Quality 3', 'Fix Quality 4', 'Fix Quality 5')
xlabel('UTMEasting values in meters')
ylabel('UTMNorthing values in meters')



