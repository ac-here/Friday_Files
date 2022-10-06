% Author: Anand Chandrasekhar
% Function computes the Ensampled average of waveforms based on the number of available
% data point. We follow the following rules while computing the average
%   Rule 1:     If more than a thershold percent of data is nan, we ingore the
%               entire waveform
%   Rule 2:     Waveform at a specific time stap is averaged if more than 1 
%               data is available. 
%               For instance, A =       nan     1       2   
%                                       0       1       3
%                                       nan     nan     1
%      	compute_mean_based_on_Nan(A) =  3/2 
%                                       4/3
%                                       nan  
% Input:        Input_signals           Waveforms should be in  the form 
%                                       of column vectors
%               Threshold_percent       If percentage of nan in a waveform 
%                                       is more than Threshold_percent,                         
%                                       discard the waveform.
% Output:       Ensampled average of waveforms
function Ensampled_Average = compute_mean_based_on_Nan(Input_signals, Threshold_percent)

    % Set the threshold percentfor discarding a waveform
    % If percentage of nan in a waveform is more than Threshold_percent,
    % discard the waveform
    if ~exist('Threshold_percent', 'var')
        Threshold_percent 	= 50;
    end
    
    if isempty(Input_signals)
        fprintf('Empty input array for compute_mean_based_on_Nan.m\n');
        Ensampled_Average = [];
        return;
    end
        
%     % This function discard a waveform if number of Nan elements 
%     % are more than a threshold set by the user
%     Input_signals = discard_waveform_based_on_Nan(Input_signals, Threshold_percent);  
%           
%     if isempty(Input_signals)
%         fprintf('Empty input array after thresholding.Error in compute_mean_based_on_Nan.m\n');
%         Ensampled_Average = [];
%         return;
%     end
    
    % This function discard a row vector if number of Nan elements
    % are more than a threshold set by the user
    Input_signals = discard_rowData_based_on_Nan(Input_signals, Threshold_percent);
    
    if isempty(Input_signals)
        fprintf('Empty input array after thresholding.Error in compute_mean_based_on_Nan.m\n');
        Ensampled_Average = [];
        return;
    end
    
    % Compute Ensampled mean
    Ensampled_Average   = nanmean(Input_signals, 2);
         
end