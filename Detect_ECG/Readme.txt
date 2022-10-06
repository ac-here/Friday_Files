Authors:        Please check individial files to see the contributions
Function:       Detect R Waves of an ECG signal using algorithms developed
                by other authors. Every author is acknolwledged in the
                main.m file. 
How to use: 	Check main.m to find examples on how to implemement this code in your project

This function is a wrapper for ECG_peak_detect.m

Following authors developed ECG_peak_detect.m 
Author(s):    Jonathan Moeyersons         (Jonathan.Moeyersons@esat.kuleuven.be)
              Sabine Van Huffel           (Sabine.Vanhuffel@esat.kuleuven.be)
              Carolina Varon              (Carolina.Varon@esat.kuleuven.be)
              Moeyersons, J., Amoni, M., Van Huffel, S., Willems, R., 
              & Varon, C. (2020). R-DECO: An open-source Matlab based graphical 
              user interface for the detection and correction of R-peaks 
              (version 1.0.0). PhysioNet. https://doi.org/10.13026/x6j7-sp58.

Following Authors implmented the Pan tomkins Algorithm
Author:       Hooman Sedghamiz            (Implemented Pan tomkins)

Following authors created a wrapper for all ECG detections presented here 
Author:       Anand Chandrasekhar         (Created a simple wrapper function)  

Requirements:
Clone this repository https://github.mit.edu/anandc/Friday_Files

In addition to ECG peak detection, there is a visualiztion tool that you
may use to manully remove detcted peaks (check manual_script_to_detect_ECG_Peaks.m). 
How to use this visualiztion tool is described here:
The visulization tool loads a window(Window_Frame) of ECG with the detected R Peaks
      If any R peaks are not detected, 
          Left Click the mouse on the R Wave
          Confirm the peak by pressing, "Space"
      If any R peaks are wrongly detected, 
          Left Click the mouse on the "wrongly detected" R Wave
          Delete the peak by pressing "delete"
      If you want to discontinue the manual detection
          Right Click the mouse.
      If you want to slide to the next window of signals,
          Press "Right Arrow"
      If you want to slide to the previous window of signals,
          Press "Left Arrow"
      You may close the figure anytime. Data will be saved
      If you identified an ROI without R peaks,
          Press "Delete"