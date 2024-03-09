#!/usr/bin/env python3
import rospy
from cmath import pi
import serial
import numpy as np
from std_msgs.msg import String
from gps_imu.msg import Vectornav
from gps_imu.srv import converttoquater
import sys

def driver():

    pub = rospy.Publisher('imu', Vectornav,queue_size=100)     
    now = rospy.get_rostime()
    #rospy.loginfo("present time %i %i", now.secs, now.nsecs
    msg = Vectornav()
    msg.Header.frame_id = 'imu1_Frame'

    while True:
        line= serdata.readline()
        linestring=line.decode("utf-8")
        #print(linestring)
        linesplit=linestring.split(",")
        
        if(linesplit[0]=="$VNYMR"):   
            roll,pitch,yaw=float(linesplit[3]),float(linesplit[2]),float(linesplit[1])
            rospy.wait_for_service('convert_to_quaternion')
            try:
                convert = rospy.ServiceProxy('convert_to_quaternion', converttoquater)
                response = convert(roll,pitch,yaw)
            except rospy.ServiceException as e:
                print("service is failed: %s"%e)
            
            magx = float(linesplit[4])
            magy = float(linesplit[5])
            magz = float(linesplit[6])
            accx = float(linesplit[7])
            accy = float(linesplit[8])
            accz = float(linesplit[9])
            gyrox = float(linesplit[10])
            gyroy = float(linesplit[11])
            gyroz = float(linesplit[12][:-5])
            
            
            msg.imu.orientation.x= float(response.qx)
            msg.imu.orientation.y= float(response.qy)
            msg.imu.orientation.z= float(response.qz)
            msg.imu.orientation.w= float(response.qw)
            msg.mag_field.magnetic_field.x=magx
            msg.mag_field.magnetic_field.y=magy
            msg.mag_field.magnetic_field.z=magz
            msg.imu.linear_acceleration.x= accx
            msg.imu.linear_acceleration.y= accy
            msg.imu.linear_acceleration.z= accz
            msg.imu.angular_velocity.x= gyrox
            msg.imu.angular_velocity.y= gyroy
            msg.imu.angular_velocity.z= gyroz
            msg.Header.stamp.secs=now.secs
            msg.Header.stamp.nsecs=now.nsecs
            msg.IMU_raw_string = linestring
        pub.publish(msg)
        print(msg)   
        rate.sleep()
            
if True:
    try:
        rospy.init_node('imu', anonymous= True)
        rate = rospy.Rate(40)
        serial_port = rospy.get_param('~port')
        serdata = serial.Serial(port=serial_port, baudrate=115200, bytesize=8, timeout = 5, stopbits= serial.STOPBITS_ONE)
        serdata.write(b"VNWRG,07,40*XX")
        driver()
    except rospy.ROSInterruptException:
        pass
