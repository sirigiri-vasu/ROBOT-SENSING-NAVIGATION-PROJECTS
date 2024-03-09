rosbag info walking_berakhis.bag;
bagselect = rosbag('walking_berakhis.bag');
bsel = select(bagselect,'Topic','/gps');
msgStructs = readMessages(bsel, 'DataFormat','struct');
msgStructs{1};
x= cellfun(@(m) double(m.UTMEasting),msgStructs);
y= cellfun(@(m) double(m.UTMNorthing),msgStructs);
z= cellfun(@(m) double(m.FixQuality),msgStructs)



f =figure
hold on
plot1 = plot(x,y, 'o', 'DisplayName','Collected Data')
grid on
title('occluded area moving data with the fit line curve')
xlabel('UTMEasting values in meters')
ylabel('UTMNorthing values in meters')

x= x(100:160);
y= y(100:160);
p= polyfit(x,y,1)

plot2 = plot(x, p(1)*x+p(2), 'r', 'DisplayName','fit line')
l = legend('show'); l.Location = 'best';

yfit = polyval(p, x);

residuals = y - yfit;
MSE = mean(residuals.^2)
RMSE =sqrt(MSE)
