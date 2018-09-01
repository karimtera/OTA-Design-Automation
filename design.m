function [M,spec]=design(spec,tech)
%% Loading Technology files
eval(['cd ' tech(1).folder]); % change directory to the technology files path
load(tech(1).name); % load tech files
load(tech(2).name);
%% Constants
kb = 1.38e-23;
To = 300;
tol = 0.00001;     %tolerance
maxNoIter = 20;     % max no. of iterations
    
VDStyp = spec.VDD / 3;
if spec.CMIR_HIGH + spec.CMIR_LOW >= spec.VDD
    input_pair_type = nch;
    current_mirror_load_type = pch;
    tail_current_source_type = nch;
    ip_type = 'n';
    load_type = 'p';
    tail_type = 'n';
else
    input_pair_type = pch;
    current_mirror_load_type = nch;
    tail_current_source_type = pch;
    ip_type = 'p';
    load_type = 'n';
    tail_type = 'p';
end
%% Input pair design

CLeff = spec.CL;
% IBIAS splits equally
Mtemp.ID = spec.IBIAS / 2;



for i = 1:maxNoIter
	if spec.GBW == -2
        Mtemp = designInputPairOptimizeGBW(input_pair_type,Mtemp.ID,spec.AO,VDStyp,spec.CIN); 
    else
        Mtemp = designInputPairGivenGBW(input_pair_type,Mtemp.ID,spec.AO,VDStyp,CLeff,spec.GBW,(spec.CMIR_LOW+spec.CMIR_HIGH)/2);
    end
    M(1) = populate(Mtemp.GM_ID, Mtemp.L, Mtemp.ID, input_pair_type, VDStyp, 0);
    M(2) = M(1);
    %% Current mirror load

    Mtemp.ID = spec.IBIAS / 2;

    % assume input pair and load have same GDS
    Mtemp.GDS = M(1).GDS;
    Mtemp.L = lookupL(current_mirror_load_type, 15, Mtemp.GDS, Mtemp.ID, VDStyp, 0, 1);
    if load_type == 'n'
        VGS_temp = spec.CMIR_LOW + M(1).VGS - M(1).VDSAT;
    else
        VGS_temp = spec.VDD - spec.CMIR_HIGH - M(1).VDSAT + M(1).VGS;
    end
    Mtemp.GM_ID_min = lookup1(current_mirror_load_type,'GM_ID','VGS',VGS_temp,'VDS',VDStyp,'VSB',0,'L',Mtemp.L);

    % Note that STH is generated for 10um width device, so you cannot get gamma by
    % dividing by M(1).GM
    M(1).gamma = lookup1(input_pair_type,'STH_GM','L',M(1).L,'VGS',M(1).VGS,'VDS',spec.VDD/3,'VSB',0) / (4 * kb * To);
    Vnin = sqrt(spec.VNOUTRMS ^ 2 * 4 * CLeff / M(1).GM);
    % Find the combination of gamma*GM that meets the spec
    gammaxGM_temp = (Vnin^2 * M(1).GM / (8*kb*To) - M(1).gamma) * M(1).GM;
    GM_ID_temp = (5:0.1:15)';
    gamma_temp = lookup1(current_mirror_load_type,'STH_GM','GM_ID',GM_ID_temp,'L',Mtemp.L) / (4 * kb * To);
    index_temp = find((gamma_temp .* GM_ID_temp) * Mtemp.ID < gammaxGM_temp,1,'last');
    Mtemp.GM_ID_max = GM_ID_temp(index_temp);
    Mtemp.gamma = gamma_temp(index_temp);
    % take GM/ID in between min and max
    Mtemp.GM_ID = (Mtemp.GM_ID_max + Mtemp.GM_ID_min) / 2;
%   Mtemp.GM_ID = 10;
    M(3) = populate(Mtemp.GM_ID,Mtemp.L,Mtemp.ID,current_mirror_load_type,VDStyp,0);
    M(4) = M(3);

    %% Capacitance correction

    dC(i) = M(2).CGS / 2 + M(2).CDB + M(4).CGD + M(4).CDB;

    if (abs((spec.CL + dC(i))/CLeff - 1) < tol || spec.GBW~=-2)
        break;
    end

    CLeff = spec.CL + dC(i);

end

%% Tail current source

Mtemp.ID = spec.IBIAS;
syms x;
Mtemp.GDS = double(solve((M(1).GM / (1 + M(1).GM * 2/x) * 1/M(3).GM == spec.AO/spec.CMRR), x));
Mtemp.L = lookupL(tail_current_source_type, 15, Mtemp.GDS, Mtemp.ID, VDStyp, 0, 1);

if tail_type == 'p'
    Mtemp.VDSATmax = double(solve((spec.CMIR_HIGH == spec.VDD - M(1).VGS - x), x));
else
    Mtemp.VDSATmax = spec.CMIR_LOW - M(1).VGS;
end
GM_ID_temp = 5:0.1:15;
VGS_temp = lookupVGS(tail_current_source_type,'GM_ID',GM_ID_temp,'L',Mtemp.L,'VDS',VDStyp,'VSB',0);
VDSAT_temp = lookup1(tail_current_source_type,'VDSAT','L',Mtemp.L,'VGS',VGS_temp,'VDS',VDStyp,'VSB',0);
VDSATmargin = 10e-3;
Mtemp.GM_ID = GM_ID_temp(find(VDSAT_temp > Mtemp.VDSATmax - VDSATmargin, 1, 'last'));
Mtemp.L = lookupL(tail_current_source_type,Mtemp.GM_ID,Mtemp.GDS,Mtemp.ID,VDStyp,0,1);
M(5) = populate(Mtemp.GM_ID,Mtemp.L,Mtemp.ID,tail_current_source_type,VDStyp,0);
M(6) = populate(Mtemp.GM_ID,Mtemp.L,Mtemp.ID/2,tail_current_source_type,VDStyp,0);
clear Mtemp;

%% SETTING VICM

if spec.CMIR_HIGH + spec.CMIR_LOW >= spec.VDD
    mn=max(spec.CMIR_LOW,M(2).VDSAT + M(5).VDSAT);
    mx=min(spec.CMIR_HIGH,spec.VDD-M(4).VDSAT);
else
   mn=max(spec.CMIR_LOW,M(4).VDSAT);
   mx=min(spec.CMIR_HIGH,spec.VDD-M(5).VDSAT-M(2).VDSAT);
end
% spec.VICM=(mn+mx)/2;
spec.VICM = 1.3;
