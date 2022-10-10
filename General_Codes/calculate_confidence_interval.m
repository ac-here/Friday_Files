% Anand Chandrasekhar
% This function calculates the confidence interval
% Input     Input:                  Data for which we need to calcualte the confidence
%                                   Interval
%           Confidence_level:       Confidence interval expressed in percentage.
%                                   default = 95.
% Output    Confidence_interval:  	You get the offset for the Margin of the
%                                   error.
%                                   Your CI will be Mean +- Margin of error.  
%           MOE:                    Margin of Error 

% [https://doi.org/10.4103/2229-3485.100662]
% Statistics plays a vital role in biomedical research. It helps present data 
% precisely and draws the meaningful conclusions. While presenting data, 
% one should be aware of using adequate statistical measures. 
% In biomedical journals, Standard Error of Mean (SEM) and Standard Deviation (SD) 
% are used interchangeably to express the variability; 
% though they measure different parameters. SEM quantifies uncertainty in 
% estimate of the mean whereas SD indicates dispersion of the data from mean. 
% As readers are generally interested in knowing the variability within sample, 
% descriptive data should be precisely summarized with SD. Use of SEM should be 
% limited to compute CI which measures the precision of population estimate.
% Journals can avoid such errors by requiring authors to adhere to their guidelines

function [Confidence_interval, MOE] = calculate_confidence_interval(Input, Confidence_level)

    % Initialize Confidence interval value
    Confidence_interval = nan;
    MOE                 = nan;

    if exist('conf_Interval', 'var')
        Confidence_level = 95;
    end
    
    if isempty(Input)
        fprintf('Input is empty\t');
        return;
    end
    
    if Confidence_level == 100  
        fprintf('Confidence interval requested is for 100%%\t');
        return;
    end

    % Check if the conf_Interval is in percentage
    if Confidence_level > 1
        Confidence_level = Confidence_level/100;
    end

    % Remove nan variables
    Input(isnan(Input)) = [];
    
    % Number of Samples
    N       = length(Input); 
    
    % Calculate the Standard Error
    SE      = std(Input, "omitnan")/sqrt(N);    

    if N > 30
        % Using the normal distribution table
        
            % Area to the left of the normal distribution             
            AL      = (1 + Confidence_level)/2;
            
            % Data from the Normal inverse cumulative distribution function 
            val = norminv(AL);
        
    else
        % Using the T Distribution table   
        
            % Alpha is the percent of data in a single tail
            alpha   = (1 - Confidence_level)/2;
            
            % Calculate the degree of freedom
            DF      = N - 1;
            
            % Data from the T Distribution table
            val = tinv(alpha,DF);
    end
    
    % Margin of Error
    MOE = val * SE;
    
    % Confidence Interval
    Mean_Val = mean(Input, "omitnan");
    Confidence_interval = [Mean_Val-MOE, Mean_Val+MOE]';
    
end