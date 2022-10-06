function detections =  tanmethod_detection(sig, t, detections, plot_me)

%[sig_pks, pks_idx, sig_vals, vals_idx] = sigpeak(sig, fs);
%[vals_idx, ~, pks_idx] = identify_valley_slope_maxima(sig, t, plot_me, 0.5, 4);
pks_idx  = detections(:, 1);
vals_idx = detections(:, 2);
%vals_idx = vals_idx';
%sig_vals = sig(vals_idx);

%Remove these lines after use
% tan_foot = vals_idx;
% return;

    tan_foot = nan(size(vals_idx));
    for n = 1:length(vals_idx)
        try 
        if isnan(vals_idx(n)), continue; end            
               
        if vals_idx(n) - 5 < 1
            temp_start = 1;
            temp_end = pks_idx(n) + 5;
        elseif pks_idx(n) + 5 > length(sig)
            temp_end = length(sig);
            temp_start = vals_idx(n) - 5;
        else
            temp_start = vals_idx(n) - 5;
            temp_end = pks_idx(n) + 5;
        end
        sig_seg     = sig(temp_start:temp_end);
        t_seg       = t(temp_start:temp_end);
        
        sigd        = gradient(sig_seg);
        td          = gradient(t_seg);
        [~, idx]    = max(sigd);
        dy          = sigd./td;
        
        k = 0;Rcorr = 1;
        while ((k < min(idx, length(sigd)-idx)-1) &&  Rcorr <= 0.999) 
            k = k+1;
            tang = (t_seg(idx-k:idx+k)-t_seg(idx))*nanmean(dy(idx-k:idx+k))+sig_seg(idx);
            R = corrcoef(tang, sig_seg(idx-k:idx+k));
            Rcorr = R(1, 2)^2;
            %fprintf('Rcorr = %3.3f Condition = %d\n', Rcorr, ~( (Rcorr <= 0.999) && (Rcorr > 0)))
        end
        tang = (t_seg-t_seg(idx))*nanmean(dy(idx-k:idx+k))+sig_seg(idx);
        %horiz = ones(size(t_seg))*sig_vals(n);
        horiz = ones(size(t_seg))*sig(vals_idx(n));
        %plot(t_seg, sig_seg, '-r', 'Linewidth', 3);hold on;
        %plot(t_seg(idx),sig_seg(idx),'ob', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
        %plot(t_seg(vals_idx(n)-temp_start),sig_seg(vals_idx(n)-temp_start),'ob', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
        %plot(t_seg, tang,'-k', 'Linewidth', 3);
        %plot(t_seg, horiz,'-k', 'Linewidth', 3);pbaspect([1 1 1]);
        
        [foot_time, ~] = polyxpoly(t_seg,horiz,t_seg,tang);
        [~, foot_time_idx] = min(abs(t_seg - foot_time));
        tan_foot(n) = round(temp_start+foot_time_idx-1);
        catch 
        end
    end
    if(plot_me == 1)
    plot(t, sig, '-k'); hold on;
    contidion = ~isnan(tan_foot);
    plot(t(pks_idx(contidion)), sig(pks_idx(contidion)), 'ob');
    plot(t(tan_foot(contidion)), sig(tan_foot(contidion)), 'or');
    end
    detections = [pks_idx tan_foot];
end