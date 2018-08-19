function spec=setDesignMode(str)
% Using this function the user can set the design mode
% it have 3 different modes
% 1) 5T_OTA
% 2) FOLDED_DT
% 3) FOLDED_CT

if(str=='5T_OTA'|str=='FOLDED_DT'|str=='FOLDED_CT')
    spec.Mode=str;
else
    disp('This mode is not available');
    return;
end

