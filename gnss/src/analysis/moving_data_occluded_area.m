rosbag info walking_berakhis.bag;
bagselect = rosbag('walking_berakhis.bag');
bsel = select(bagselect,'Topic','/gps');
msgStructs = readMessages(bsel, 'DataFormat','struct');
msgStructs{1}



x= cellfun(@(m) double(m.UTMEasting),msgStructs);
y= cellfun(@(m) double(m.UTMNorthing),msgStructs);




X = x-x(1);
Y = y-y(1);

scatter(X,Y)
grid on
hold on

title('scatterplot of moving data occluded area')
xlabel('UTMEasting values in meters')
ylabel('UTMNorthing values in meters')


