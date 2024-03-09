%1. Estimate the heading(yaw)
%This script consists of the magnetometer calibration using the
%data_going_in_circles.bag 

bag = rosbag("data_going_in_circles.bag");
topic = select(bag, 'Topic', '/imu');
msgs = readMessages(topic , 'DataFormat','struct');
msgs{1}.MagField;
Mag_x_val = cellfun(@(i) double(i.MagField.MagneticField_.X),msgs);
Mag_y_val = cellfun(@(i) double(i.MagField.MagneticField_.Y),msgs);
Mag_z_val = cellfun(@(i) double(i.MagField.MagneticField_.Z),msgs);

%dEFORE CORRECTIONS----------------------------------------------------
figure(1)
[xfit,yfit,Rfit] = circfit(Mag_x_val,Mag_y_val);
plot(Mag_x_val,Mag_y_val, 'color','green')
hold on
rectangle('position',[xfit-Rfit,yfit-Rfit,Rfit*2,Rfit*2],...
    'curvature',[1,1],'linestyle','-','edgecolor','b');
axis equal
grid on;

ellipse_t = fit_ellipse(Mag_x_val,Mag_y_val);
syms x y 
% ellipse axis 
% a=ellipse_t.long_axis/2;   
d=ellipse_t.short_axis/2;
%ellipse center
h=ellipse_t.X0_in; k=ellipse_t.Y0_in;
%ellipse equation
ellipse= (((x-h)^2)/(a^2))+(((y-k)^2)/(d^2))==1;
%plot the ellipse
plotZoom=(max(a,d)+max(abs(h), abs(k)))+1;
fimplicit(ellipse, [-plotZoom plotZoom],'color', 'black'); 
%plot([-plotZoom plotZoom], [0 0], '-k ');
%plot([0 0 ], [-plotZoom plotZoom], '-k');
%plot(h, k, 'd');

xlabel('magnetic field x (Gauss)')
ylabel('magnetic field y (Gauss)')
title('magnetic field in y vs magnetic field in x')

axis equal;

%AFTER CORRECTIONS---------------------------------------------------------
offsetx = ellipse_t.X0_in;
offsety = ellipse_t.Y0_in;
Mag_x_val_transl = Mag_x_val-offsetx;
Mag_y_val_transl = Mag_y_val-offsety;

ellipse_t = fit_ellipse(Mag_x_val_transl,Mag_y_val_transl);
angle = ellipse_t.phi;

rotationmat = [cos(angle), sin(angle);...
  -sin(angle), cos(angle)];
Mag_x_valy = [Mag_x_val_transl, Mag_y_val_transl];
Mag_x_valy_rot = Mag_x_valy * rotationmat;
Mag_x_val_rot = Mag_x_valy_rot(:,1);
Mag_y_val_rot = Mag_x_valy_rot(:,2);
ellipse_t = fit_ellipse(Mag_x_val_rot,Mag_y_val_rot);

tau = (ellipse_t.short_axis/2)/(ellipse_t.long_axis/2);
rescaling_mat = [tau,0;0,1];

Mag_x_valy_rot = Mag_x_valy_rot*rescaling_mat;

Mag_x_val_final = Mag_x_valy_rot(:,1);
Mag_y_val_final = Mag_x_valy_rot(:,2);
figure(1);
plot(Mag_x_val_final, Mag_y_val_final, 'color', 'yellow')
grid on;
axis equal;

[xfit,yfit,Rfit] = circfit(Mag_x_val_final,Mag_y_val_final);
rectangle('position',[xfit-Rfit,yfit-Rfit,Rfit*2,Rfit*2],...
    'curvature',[1,1],'linestyle','-','edgecolor','r');

syms x y 
% ellipse axis 
a=ellipse_t.long_axis/2;   
d=ellipse_t.short_axis/2;
%ellipse center
h=ellipse_t.X0_in; k=ellipse_t.Y0_in;
%ellipse equation
ellipse= (((x-h)^2)/(a^2))+(((y-k)^2)/(d^2))==1;
%plot the ellipse
plotZoom=(max(a,d)+max(abs(h), abs(k)))+1;
fimplicit(ellipse, [-plotZoom plotZoom], ...
    'color', 'black'); 
plot([-plotZoom plotZoom], [0 0], '-k');
plot([0 0 ], [-plotZoom plotZoom], '-k');
plot(h, k, 'd');
axis equal;
hold off;



