#!/usr/bin/env python
from collections import deque
import csv, time, schedule
import os
import sys
import urllib            # URL functions
import urllib2           # URL functions

filename="/tmp/temp.csv"
THINGSPEAKKEY = 'INSERTYOURTHINGSPEAKKEYHERE'
THINGSPEAKURL = 'https://api.thingspeak.com/update'


def getLast(csv_filename):
    with open(csv_filename, 'r') as f:
        try:
            lastrow = deque(csv.reader(f), 1)[0]
        except IndexError:  # empty file
            lastrow = None
        return lastrow

def getLast_v2(csv_filename):
    with open(csv_filename, 'r') as f:
        lastrow = None
        for lastrow in csv.reader(f): pass
	return lastrow

def sendData(url,key,field1,field2,field3,field4,field5,field6,field7,field8,
		data1,data2,data3,data4,data5,data6,data7,data8):
  """
  Send event to internet site
  """

  values = {
		'api_key' : key,
		'field1' : data1,
		'field2' : data2,
		'field3' : data3,
		'field4' : data4,
		'field5' : data5,
		'field6' : data6,
		'field7' : data7,
		'field8' : data8
}

  postdata = urllib.urlencode(values)
  req = urllib2.Request(url, postdata)

  log = time.strftime("%d-%m-%Y,%H:%M:%S") + ","
  log = log + data1 + ","
  log = log + data2 + ","
  log = log + data3 + ","
  log = log + data4 + ","
  log = log + data5 + ","
  log = log + data6 + ","
  log = log + data7 + ","
  log = log + data8 + ","

  try:
    # Send data to Thingspeak
    response = urllib2.urlopen(req, None, 5)
    html_string = response.read()
    response.close()
    log = log + 'Update ' + html_string

  except urllib2.HTTPError, e:
    log = log + 'Server could not fulfill the request. Error code: ' + e.code
  except urllib2.URLError, e:
    log = log + 'Failed to reach server. Reason: ' + e.reason
  except:
    log = log + 'Unknown error'

  print log

if __name__ == "__main__":
	while 1:
		try:
			temp_data=getLast(filename)

			data={
				"SOUTHWEST":temp_data[1],
				"SOUTH":temp_data[2],
				"SOUTHEAST":temp_data[3],
				"WEST":temp_data[4],
				"ORIGIN":temp_data[5],
				"EAST":temp_data[6],
				"NORTHWEST":temp_data[7],
				"NORTH":temp_data[8],
				"NORTHEAST":temp_data[9]
		     	}

		#print data
			sendData(THINGSPEAKURL,THINGSPEAKKEY,'field1','field2','field3',
				'field4','field5','field6','field7','field8',
				data['SOUTHWEST'],data['SOUTH'],data['SOUTHEAST'],data['WEST'],
				data['EAST'],data['NORTHWEST'],data['NORTH'],data['NORTHEAST'])
			time.sleep(60)
		except:
			pass