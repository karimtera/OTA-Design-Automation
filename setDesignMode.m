function DESIGN=setDesignMode(DESIGN,str)
% Using this function the user can set the design mode
% it have 3 different modes
% 1) 5T_OTA
% 2) FOLDED_DT
% 3) FOLDED_CT

if(str == '5T_OTA' | str == 'FOLDED_DT' | str == 'FOLDED_CT')
    DESIGN.mode = str;
    param = {'VDD','IBIAS','CL','CIN','AO','CMRR','CMIR_HIGH','CMIR_LOW','VNOUTRMS','VICM','GBW'}; % all specs
    for i=1:11
        eval(['DESIGN.spec.' param{i} '=-1;']); % initialize all specs as ( -1 : not specified yet )
    end
    DESIGN.flag(1:11) = -1;
else
    disp('This mode is not available');
    return;
end

