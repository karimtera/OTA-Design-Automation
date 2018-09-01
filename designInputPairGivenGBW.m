function M = designInputPairGivenGBW(type,ID,AO,VDS,CL_EFF,GBW)
% this function design input pair transistors assuming that both
% transistors M1 and M2 have the same output conductance

GM = GBW*2*pi*CL_EFF;
GDS = GM/2/AO;
M.GM_ID = GM/ID;
M.L = lookupL(type,M.GM_ID,GDS,ID,VDS,0,1);
M.ID = ID;
