#!/bin/bash

# Loud fan control script to lower speed of fun based on current
# max temperature of any cpu
#
# See README.md for details.


if [ -f /sys/devices/odroid_fan.13/fan_mode ]; then
   FAN=13
elif [ -f /sys/devices/odroid_fan.14/fan_mode ]; then
   FAN=14
else
   echo "This machine is not supported."
   exit 1
fi

FAN_MODE_FILE="/sys/devices/odroid_fan.$FAN/fan_mode"

#make sure after quiting script fan goes to auto control
if [ "$1" == "stop" ]
then
	echo 1 > $FAN_MODE_FILE
fi

if [ "$1" == "start" ]
then

	TEMPERATURE_FILE="/sys/devices/10060000.tmu/temp"
	FAN_SPEED_FILE="/sys/devices/odroid_fan.$FAN/pwm_duty"
	TEST_EVERY=3 #seconds

	exit_xu3_only_supported () {
	  exit 2
	}
	if [ ! -f $TEMPERATURE_FILE ]; then
	  exit_xu3_only_supported "no temp file"
	elif [ ! -f $FAN_MODE_FILE ]; then
	  exit_xu3_only_supported "no fan mode file"
	elif [ ! -f $FAN_SPEED_FILE ]; then
	  exit_xu3_only_supported "no fan speed file"
	fi


	current_max_temp=`cat $TEMPERATURE_FILE | cut -d: -f2 | sort -nr | head -1`
	echo "fan control started. Current max temp: $current_max_temp"

	prev_fan_speed=0
	echo 0 > $FAN_MODE_FILE #to be sure we can manage fan
	while [ true ];
	do

	  current_max_temp=`cat $TEMPERATURE_FILE | cut -d: -f2 | sort -nr | head -1`
	  #echo $current_max_temp

	  new_fan_speed=0
	  if [ $current_max_temp -ge 75000 ]
	  then
		new_fan_speed=255
	  elif [ $current_max_temp -ge 70000 ]
	  then
		new_fan_speed=200
	  elif [ $current_max_temp -ge 68000 ]
	  then
		new_fan_speed=130
	  elif [ $current_max_temp -ge 66000 ]
	  then
		new_fan_speed=70
	  elif [ $current_max_temp -ge 63000 ]
	  then
		new_fan_speed=70
	  elif [ $current_max_temp -ge 60000 ]
	  then
		new_fan_speed=70
	  elif [ $current_max_temp -ge 58000 ]
	  then
		new_fan_speed=70
	  elif [ $current_max_temp -ge 55000 ]
	  then
		new_fan_speed=70
	  else
		#0
		new_fan_speed=70
	  fi

	  if [ $prev_fan_speed -ne $new_fan_speed ]
	  then
		echo $new_fan_speed > $FAN_SPEED_FILE
		prev_fan_speed=$new_fan_speed
	  fi

	  sleep $TEST_EVERY
	done
fi
