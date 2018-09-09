function printTable(model)
% print transistors parameters in table

for i=1:11
   if model.flag(i) == -2
       return;
   end
end

if model.mode=='5T_OTA'
    parameters = {'L','W','GM_ID','GM_GDS','ID','VGS','VDSAT','GM','GDS'};
    T = struct2table(model.M,'RowNames',{'M1','M2','M3','M4','M5','M6'});
    T = T(:,parameters)
end
