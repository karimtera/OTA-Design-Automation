function printTable(DESIGN)
% print transistors parameters in table

for i=1:11
   if ~DESIGN.flag(i)
       return;
   end
end

if DESIGN.mode=='5T_OTA'
    parameters = {'L','W','GM_ID','GM_GDS','ID','VGS','VDSAT','GM','GDS'};
    T = struct2table(DESIGN.M,'RowNames',{'M1','M2','M3','M4','M5','M6'});
    T = T(:,parameters)
end