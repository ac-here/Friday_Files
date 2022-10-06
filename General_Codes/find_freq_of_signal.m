function [Samples_beat, Fund_Freq] = find_freq_of_signal(Fs, Signal, MIN_FREQ, MAX_FREQ, plot_Freq)

    % Sampling rate is Fs

    % Order of FFT (Should be even number)
    N_FFT       = 1024;

    if ~exist('MAX_FREQ', 'var')
        MAX_FREQ = 4;
    end

    if ~exist('MIN_FREQ', 'var')
        MIN_FREQ = 0.5;
    end
    
    if ~exist('plot_Freq', 'var')
        plot_Freq = false;
    end
    
    % Remove mean of the signal
    Signal   	= Signal - mean(Signal, 'omitnan');

    % Compute FFT
    fft_abs     = fftshift(abs(fft(Signal, N_FFT)));

    % Freq axis of the FFT computation
    freq_axis   = linspace(-Fs/2, Fs/2, N_FFT)';

    %%Plot the results
    %plot(freq_axis, fft_abs, '-k');

    % Crop FFT and Freq_axis based on this limits
    Index           = (freq_axis>=MIN_FREQ & freq_axis<=MAX_FREQ);
    crop_fft        = fft_abs(Index);
    crop_freq_axis  = freq_axis(Index);
    

    % Locate the peak of the FFT
    [~, max_Index]  = max(crop_fft);

    % Find the fundamental Frequency
    Fund_Freq       = crop_freq_axis(max_Index);

    % Number of samples in a beat
    Samples_beat    = floor(1./Fund_Freq * Fs);
    
    if plot_Freq
        plot(crop_freq_axis, crop_fft, '-k', 'LineWidth', 3); hold on;
        xlabel('Frequency [Hz]'); ylabel('FFT Amplitude [a.u]');
        plot([Fund_Freq Fund_Freq], [0 max(crop_fft)], '-r', 'LineWidth', 3);
    end

end