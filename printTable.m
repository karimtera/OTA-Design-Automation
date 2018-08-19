function printTable(M,mode)
% print transistors parameters in table

if mode=='5T_OTA'
    parameters = {'L','W','GM_ID','GM_GDS','ID','VGS','VDSAT','GM','GDS'};
    T = struct2table(M,'RowNames',{'M1','M2','M3','M4','M5','M6'});
    T = T(:,parameters)
end