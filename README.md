# CMVS
WPI Cloud Motion Vector System

The most recent matlab scripts are in the MATLAB_CMV directory

To Access the main.m file:
CMVS-master > MATLAB_CMV > main.m
This is where the improvements made to the MATLAB code for the academic year 2021-2022 occurred.

Arduino Code:
To operate the sensors, such that data collection can begin on the array. Upload the readsensors.ino file.
CMVS-master > Arduino > readsensors > readsensors.ino

ThingSpeak:
Reference the file: ThingsSpeak > thinkspeak code.txt
Open this text file then pase it into the Visualization tab on ThingSpeak. You will need to adjust the API read & write keys, such that they match those of the channels of the account user. I do not recommend using the other code from the ThingSpeak folder as it is outdated. Even with the code from this recent year, I suggest improving its efficiency comparable to that of the MATLAB script. The cloud size and depth have not been retroactively added to the MATLAB, as they currently are on the "thingspeak code.txt" file.

Scripts for Hammad's model:
These scripts are located in the file Predicted_power_scripts. The goal was to input live irradiance and temperature sensor values to a Simulink model to predict the output power of the PV array. As we were having major difficulties with directly collecting these values with Simulink, we used a series of programs to go from Arduino to Simulink. The Arduino program (readTempAndLicor.ino) is what enables the Arduino to convert received signals to temperature and irradiance values that we understand. A python program (either readSerial-dependent.py or readSerial-independent.py) is used to read the COM port that the Arduino script is writing values to. Python file "readSerial-independent.py" can be ran by itself and will continously print detected sensor values. Python file "readSerial-dependent.py" is used by the Matlab script "readSerialMatlab.m" to save the detected sensor values as usuable variables in Matlab. Due to a limitation in Matlab, the script must be run continously to display updated values. The Matlab script isn't able to be integrated with the Simulink model because a command needed to run the python script (pyrunfile) isn't supported in Simulink. This leads to our recommendation of focusing on trying to use Arduino directly through Simulink. While this may lead to having to swap out the specific DHT22 temperature sensor with a termistor (for ease of use), this will allow for a much more streamlined and less complex work flow.

PCB & Solidworks DESIGNS:
These PCBs can be found in the "PCBs_&_Solidworks" file. There are several iterations of designed PCBs. The largest PCB is not present in our deliverables because it was designed by a graduate student and not the undergrads.
* The "RJ45_CMVS_PCB_V2" located in the PCB Designing by Steve is designed for an Ethernet array approach using the Arduino Nano IoT 33.
* The "RJ45_CMVS_PCB_V3" located in the PCB Designing by Steve is designed for standard array approach using the Arduino Nano IoT 33.
* The "MQP CMVS PCB" PCB design was created by the undergraduate team and is what we propose to be used when this project is continued.