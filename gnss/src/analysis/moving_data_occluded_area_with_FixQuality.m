rosbag info walking_berakhis.bag;
bagselect = rosbag('walking_berakhis.bag');
bsel = select(bagselect,'Topic','/gps');
msgStructs = readMessages(bsel, 'DataFormat','struct');
msgStructs{1};
x= cellfun(@(m) double(m.UTMEasting),msgStructs);
y= cellfun(@(m) double(m.UTMNorthing),msgStructs);
z= cellfun(@(m) double(m.FixQuality),msgStructs);

scatter(x,y, 20, z,"filled");
colormap(jet);
colorbar;
grid on
title('moving data occluded area with Fix Quality values')
xlabel('UTMEasting values in meters')
ylabel('UTMNorthing values in meters')

