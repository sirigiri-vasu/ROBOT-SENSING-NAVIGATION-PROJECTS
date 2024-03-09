#!/usr/bin/env python3

from __future__ import print_function

from gps_imu.srv import converttoquater,converttoquaterResponse
import rospy
from cmath import pi
import numpy as np 

def handle(req):
    radians_r=float(req.roll)*pi/180
    radians_p=float(req.pitch)*pi/180
    radians_y=float(req.yaw)*pi/180
    
    qx = np.sin(radians_r/2) * np.cos(radians_p/2) * np.cos(radians_y/2) - np.cos(radians_r/2) * np.sin(radians_p/2) * np.sin(radians_y/2)
    qy = np.cos(radians_r/2) * np.sin(radians_p/2) * np.cos(radians_y/2) + np.sin(radians_r/2) * np.cos(radians_p/2) * np.sin(radians_y/2)
    qz = np.cos(radians_r/2) * np.cos(radians_p/2) * np.sin(radians_y/2) - np.sin(radians_r/2) * np.sin(radians_p/2) * np.cos(radians_y/2)
    qw = np.cos(radians_r/2) * np.cos(radians_p/2) * np.cos(radians_y/2) + np.sin(radians_r/2) * np.sin(radians_p/2) * np.sin(radians_y/2)
    
    return converttoquaterResponse(qx , qy, qz, qw)
    
    
def convert_to_quaternion():

    rospy.init_node("convert_to_quaternion")
    s= rospy.Service("convert_to_quaternion", converttoquater, handle)
    
    #print("ready to add two ints.")
    rospy.spin()
    
if __name__ == "__main__":
    convert_to_quaternion()
    

