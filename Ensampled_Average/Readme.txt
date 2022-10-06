Authors:        Anand Chandrasekhar
Function:       Computes ensampled average of Physiological waveforms. 
How to use: 	Check main.m to find examples on how to implemement this code in your project

This function takes a time domain biomedical signal like Tonometric 
waveform or a PPG waveform, and split the signals into differnt beats to 
make a represenative aka ensampled-averaged beat. At present, we use
R-Waves of an ECG signal to perform the beat splitting. The program has a
feature to allow users to visualize the beats and decide to remove any
beat based on morphology/shape in comparison to the rest of
the beats. 

Requirements:
Clone this repository https://github.mit.edu/anandc/Friday_Files

How to use this function 
Here, A figure pops up with all beats plotted on the same X axis.
To select the beats with a Left Mouse Click, and then press "DELETE". 
Close the figure after removing all the necessary beats.


