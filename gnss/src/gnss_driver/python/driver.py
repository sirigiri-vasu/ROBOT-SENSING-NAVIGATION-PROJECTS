#!/usr/bin/python3

from curses import raw
import rospy
import serial
import utm
import math
from gnss_driver.msg import gps_msg
import sys
from std_msgs.msg import String


ser = serial.Serial(sys.argv[1])
ser.baudrate = 4800

def parsing(ser_line):
	ls = ser_line.split(",")
	latitude_raw = float(ls[2])
	latitude_raw = latitude_raw/100
	minutes,degrees = math.modf(latitude_raw)
	latitude = degrees + 100*minutes/60
	if ls[3] == "S":
	
		latitude = -latitude
	longitude_raw = float(ls[4])
	longitude_raw = longitude_raw/100
	minutes,degrees = math.modf(longitude_raw)
	longitude = degrees + 100*minutes/60
	if ls[5] == "W":
		longitude = -longitude
	altitude = float(ls[9])
	hdop = float(ls[8])
	utc1 = float(ls[1])
	stamp = float(ls[1])
	fix_quality = int(ls[6])
	
	return latitude,longitude,altitude,hdop,utc1, fix_quality
	

def parse_time(serline) :
	ls = serline.split(",")
	raw_time = ls[1]
	l = len(raw_time)
	seconds = float(raw_time[l-7:l-1])
	minutes = float(raw_time[l-10:l-8])
	hours = float(raw_time[0:l-11])
	
	time_secs = hours*3600 + minutes*60 + seconds
	return time_secs

def sensor():
	pub = rospy.Publisher('/gps',gps_msg, queue_size = 5)
	pubGNGGA = rospy.Publisher('/gpgga',String,queue_size = 5)
	rospy.init_node('gps_sensor', anonymous = True)
	
	r = rospy.Rate(1)
	msg = gps_msg()
	gnggastring = String()
	msg.Header.seq = 0
	msg.Header.frame_id = "GPS1_Frame"
	
	while not rospy.is_shutdown():
		ser_line = ser.readline().decode("utf-8")  
		
		
		GNGGA = "GNGGA"
		if GNGGA in ser_line:
			
			msg.Header.seq+=1
			gnggastring.data = ser_line
			rospy.loginfo(ser_line)
			latitude,longitude,altitude,utc1,hdop,fix_quality = parsing(ser_line)
			
			rospy.loginfo("Latitude :"+ str(latitude))
			
			rospy.loginfo("Longitude :" + str(longitude)) 
			
			utm_coordinates = utm.from_latlon(latitude,longitude)
			rospy.loginfo(utm_coordinates)
			rospy.loginfo("Altitude :" + str(altitude))
			
			
			time_stamp = parse_time(ser_line)
			msg.Header.stamp = rospy.Time.from_sec(time_stamp)
			msg.Latitude = latitude
			msg.Longitude = longitude
			msg.Altitude = altitude
			msg.HDOP = hdop
			msg.UTC = utc1
			msg.UTM_easting = utm_coordinates[0]
			msg.UTM_northing = utm_coordinates[1]
			msg.Zone = utm_coordinates[2]
			msg.Letter = utm_coordinates[3]
			msg.fix_quality = fix_quality
			#rospy.loginfo(msg)
			pub.publish(msg)
			pubGNGGA.publish(gnggastring)

			r.sleep()	


if __name__ == '__main__':
	try:
		sensor()
	except rospy.ROSInterruptException: pass


	

