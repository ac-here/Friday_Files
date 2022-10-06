% This function is a wrapper for ECG_peak_detect.m

% Following authors developed ECG_peak_detect.m 
% Author(s):    Jonathan Moeyersons         (Jonathan.Moeyersons@esat.kuleuven.be)
%               Sabine Van Huffel           (Sabine.Vanhuffel@esat.kuleuven.be)
%               Carolina Varon              (Carolina.Varon@esat.kuleuven.be)

% Following Authors implmented the Pan tomkins Algorithm
% Author:       Hooman Sedghamiz            (Implemented Pan tomkins)

% Following authors created a wrapper for ECG_peak_detect.m 
% Author:       Anand Chandrasekhar         (Created a simple wrapper function)   

% Requirements:
% Signal Processing Toolbox of MATLAB
% "General_Codes" in https://github.mit.edu/anandc/Friday_Files

% Input     :   time            (Units Seconds)
%               ecg 
%               HR              (Optional- Heart Rate in Hz)
%                               If duration of the study is more than 3 minutes, 
%                               FFT computation may be very expensive and time
%                               consuming. You may add this HR variable to avoid FFT
%                               computation
% Ouput     :   R_wave_Out    	Index Postions for the R waves
%                               I have implemented various algorithms from
%                               different authors. For example, putput from 
%                               first algorithm is saved as follows:
%                               R_wave_Out(1).detections
%                               R_wave_Out(1).algorithm
        
function R_wave_Out = find_R_Wave_ECG(time, ecg, HR)
   
    % Sampling rate of the signal
    Fs                  = 1/mean(diff(time));
    
    % Initizlize a structure to save results
    R_wave_Out          = struct();
    
    % Implement Pan Tomkins Algorithms
    try
        [~, QRS_index]      = pan_tompkin(ecg, floor(Fs), 0);
        R_wave_Out(1).detections 	= QRS_index(:);
        R_wave_Out(1).algorithm     = 'Pan Tomkins'; 


        % Clean up the detections from Pan Tomkins Algorithms using 
        % basic peak detection and save the results
        R_wave_Out(2).detections 	= remove_unwanted_R_waves_using_QRS_complex( ...
                                        R_wave_Out(1).detections, time, ecg);
        R_wave_Out(2).algorithm     = 'Pan Tomkins with basic processing'; 

        if(nargin == 2)
            HR              = mean(diff(R_wave_Out(2).detections))/Fs;
        end   
    catch
        R_wave_Out(1).detections 	= [];
        R_wave_Out(1).algorithm     = [];
        R_wave_Out(2).detections 	= [];
        R_wave_Out(2).algorithm     = [];
        HR                          = 1; % Initializing to a default value
    end
     
    % Implement ECG_peak_detect.m
    % I have not figured out how to set these parameters.
    % I have used default paramters set by the Author.
    try
        % Use 100 for mouse data
        % Use 300 for Human data
        parameters          = {100, mean(HR), 0, 0, 0};
        [R_peak, ~, ~, ...
            check]          = ECG_peak_detect(parameters, ecg, Fs);
        if(check == 1)
            Dummy                           = R_peak{1};
            R_wave_Out(3).detections        = Dummy(:);
            R_wave_Out(3).algorithm         = 'ECG-peak-detect.m';

        else
            R_wave_Out(3).detections        = [];
            R_wave_Out(3).algorithm         = 'ECG-peak-detect.m';       
        end
    catch
        R_wave_Out(3).detections        = [];
        R_wave_Out(3).algorithm         = 'ECG-peak-detect.m';
    end
    %close; plot(time, ecg); hold on; plot(time(R_wave_Out(3).detections), ecg(R_wave_Out(3).detections), 'ok'); hold off;      
end