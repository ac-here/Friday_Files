% Author: Anand Chandrasekhar

% This function is called when the figure is closed.
% This functions saves the Y axis of the plots and save in 
% the property "UserData".

% We are also using a Javabot to mimc key Press
% Here we are mimcing "RETURN/ENTER" key. WE mimic this key press
% to exit the waitforbuttonpress() function.

function my_closereq(src, callbackdata)

    data.output     = extract_Y_data_figure();
    data.flag       = true;
    
    callbackdata.Source.UserData = data;  
    
    % Emulate KEY pressing.
    % We need this to break the loop
    import java.awt.Robot;
    import java.awt.event.InputEvent;
    
    key = Robot();
    key.keyPress(java.awt.event.KeyEvent.VK_ENTER);
    %key.keyRelease(java.awt.event.KeyEvent.VK_ENTER);
    
end