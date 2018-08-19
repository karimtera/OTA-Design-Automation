function M = designInputPairGivenGBW(type,ID,AO,VDS,CL_EFF,GBW,VICM)
% this function design input pair transistors assuming that both
% transistors M1 and M2 have the same output conductance
VSB = VDS;
VGS = VICM - VSB; % note that VICM should be larger than VDS by VTH
for i=1:10
    syms gm;
    if i==1
        GM = double(solve(2*(gm+0.3*gm*VSB/VGS)/(1+gm/(gm+0.3*gm*VSB/VGS)+0.3*gm*VSB/VGS)==2*pi*GBW*CL_EFF, gm));
        GM_ID = GM/ID;
        GDS = 2*(GM+0.3*GM*VSB/VGS)/(1+GM/(GM+0.3*GM*VSB/VGS)+0.3*GM*VSB/VGS)/2/AO;
    else
        GM = double(solve(2*(gm+GMB*VSB/VGS)/(1+gm/(gm+GMB*VSB/VGS)+GMB*VSB/VGS)==2*pi*GBW*CL_EFF, gm));
        GM = GM(GM>0);
        GM_ID = GM/ID;
        GDS = 2*(GM+GMB*VSB/VGS)/(1+GM/(GM+GMB*VSB/VGS)+GMB*VSB/VGS)/2/AO;
    end
    L = lookupL(type,GM_ID,GDS,ID,VDS,VSB,1);
    VGS = lookupVGS(type,'GM_ID',GM_ID,'L',L,'VDS',VDS,'VSB',VSB);
    VSB = VICM - VGS; 
    GMB_GM = lookup1(type,'GMB_GM','GM_ID',GM_ID,'L',L,'VDS',VDS,'VSB',VSB); 
    GMB = GMB_GM*GM_ID*ID;
end

% GM = GBW*2*pi*CL_EFF;
% GDS = GM/2/AO;
% M.GM_ID = GM/ID;
% M.L = lookupL(type,M.GM_ID,GDS,ID,VDS,0,1);
M.GM_ID = GM_ID;
M.L = L;
M.ID = ID;
M.VSB = VSB;

