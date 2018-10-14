function DESIGN=setSpec(DESIGN,varargin)
% this function sets the specs of the DESIGN  
% in order for this fuction to work correctly the user should pass one of
% these parameters only one time:
% 'VDD','IBIAS','CL','CIN','AO','CMRR','CMIR_HIGH','CMIR_LOW','VNOUTRMS','VICM','GBW'.
% some special codes you can enter:
% 1) if you want to optimize on this parameter, enter -2 (only for GBW so
% far)

for i=1:11
   if ~DESIGN.flag(i)
       return;
   end
end

if nargin > 3
    fprintf('Error: setSpec function only sets one spec at a time');
    return;
end


param = {'VDD','IBIAS','CL','CIN','AO','CMRR','CMIR_HIGH','CMIR_LOW','VNOUTRMS','VICM','GBW'};

if isempty(find(strcmp(param,varargin{1}),1)) % if the spec is not found in the parameters cell, terminate
    fprintf('Error: this spec %s is not defined, please read setSpec help\n',varargin{1});
    return;
end

eval(['DESIGN.spec.' varargin{1} '=' num2str(varargin{2}) ';']); % add the required spec

if DESIGN.spec.CL ~= -1 && DESIGN.spec.IBIAS ~= -1 && DESIGN.spec.GBW ~= -2 && DESIGN.spec.GBW~=-1 && DESIGN.flag(1) == -1 
	DESIGN.temp.GM_1 = 2 * pi * DESIGN.spec.GBW * DESIGN.spec.CL ;
    DESIGN.temp.GM_ID_1 = DESIGN.temp.GM_1 / (DESIGN.spec.IBIAS/2);
    if DESIGN.temp.GM_ID_1 < 5 || DESIGN.temp.GM_ID_1 > 16
        fprintf('Error: this GBW can not be realized given ID and CL\n'); 
        DESIGN.flag(1) = 0;
        return;
    end
    DESIGN.flag(1) = 1;
    
end

if DESIGN.spec.CMIR_LOW ~= -1 && DESIGN.flag(2) == -1
    if DESIGN.spec.CMIR_LOW < 0 
        fprintf("Error: the CMIR should at least start from 0 voltage\n");
        DESIGN.flag(2) = 0;
        return;
    end
    DESIGN.flag(2) = 1;
end

if DESIGN.spec.CMIR_HIGH ~= -1 && DESIGN.flag(3) == -1
    if DESIGN.spec.CMIR_HIGH < 0
        fprintf("Error: the CMIR should at least start from 0 voltage\n");
        DESIGN.flag(3) = 0;
        return;
    end
    DESIGN.flag(3) = 1;
end


if DESIGN.flag(2) == 1 && DESIGN.flag(3) == 1 && DESIGN.spec.VDD ~= -1 && DESIGN.flag(4) == -1
    if DESIGN.spec.CMIR_HIGH > DESIGN.spec.VDD
        fprintf("Error: the CMIR should at most end at VDD\n");
        DESIGN.flag(4) = 0;
        return;
    end
    if DESIGN.spec.CMIR_HIGH < DESIGN.spec.CMIR_LOW
        fprintf("Error: the (end)CMIR is not correctly defined\n");
        DESIGN.flag(4) = 0;
        return;
    end
    DESIGN.flag(4) = 1;
end

if DESIGN.spec.AO ~= -1 && DESIGN.flag(1) == 1 && DESIGN.flag(4) == 1 && DESIGN.flag(5) == -1
    eval(['cd ' DESIGN.file(1).folder]); % change directory to the technology files path
    load(DESIGN.file(1).name); % load tech files
    load(DESIGN.file(2).name);
    DESIGN.temp.GDS_1 = DESIGN.temp.GM_1 / DESIGN.spec.AO / 2;
    DESIGN.temp.GM_GDS_1 = DESIGN.temp.GM_1 / DESIGN.temp.GDS_1;
    if DESIGN.spec.CMIR_HIGH + DESIGN.spec.CMIR_LOW >= DESIGN.spec.VDD
        input_pair_type = nch;
    else
        input_pair_type = pch;
    end
    min_gain = lookup1(input_pair_type,'GM_GDS','GM_ID',5,'L',input_pair_type.L(1),'VDS',DESIGN.spec.VDD/3,'VSB',0);
    max_gain = lookup1(input_pair_type,'GM_GDS','GM_ID',15,'L',input_pair_type.L(end),'VDS',DESIGN.spec.VDD/3,'VSB',0);
    if DESIGN.temp.GM_GDS_1 > max_gain || DESIGN.temp.GM_GDS_1 < min_gain
       fprintf("Error: this gain cannot be realized given the technology\n"); 
       DESIGN.flag(5) = 0;
       return;
    else
        DESIGN.temp.L_1 = lookupL(input_pair_type,DESIGN.temp.GM_ID_1 ,DESIGN.temp.GDS_1 ,DESIGN.spec.IBIAS/2,DESIGN.spec.VDD/3,0,1);
        DESIGN.temp.VGS_1 = lookupVGS(input_pair_type,'GM_ID',DESIGN.temp.GM_ID_1,'L',DESIGN.temp.L_1,'VDS',DESIGN.spec.VDD/3,'VSB',0);
        DESIGN.temp.VDSAT_1 = lookup1(input_pair_type,'VDSAT','L',DESIGN.temp.L_1,'VGS',DESIGN.temp.VGS_1,'VDS',DESIGN.spec.VDD/3,'VSB',0);
    end
    DESIGN.flag(5) = 1;
end


if DESIGN.flag(4) == 1 && DESIGN.flag(5) == 1 && DESIGN.flag(6) == -1
    eval(['cd ' DESIGN.file(1).folder]); % change directory to the technology files path
    load(DESIGN.file(1).name); % load tech files
    load(DESIGN.file(2).name);
    if DESIGN.spec.CMIR_HIGH + DESIGN.spec.CMIR_LOW >= DESIGN.spec.VDD
        input_pair_type = nch;
        current_mirror_load_type = pch;
        DESIGN.temp.VGS_3 = DESIGN.spec.VDD - DESIGN.spec.CMIR_HIGH - DESIGN.temp.VDSAT_1 + DESIGN.temp.VGS_1;
    else
        input_pair_type = pch;
        current_mirror_load_type = nch;
    	DESIGN.temp.VGS_3 = DESIGN.spec.CMIR_LOW + DESIGN.temp.VGS_1 - DESIGN.temp.VDSAT_1;
    end
    max_vgs = lookupVGS(current_mirror_load_type,'GM_ID',5,'L',current_mirror_load_type.L(1),'VDS',DESIGN.spec.VDD/3,'VSB',0);
    min_vgs = lookupVGS(current_mirror_load_type,'GM_ID',15,'L',current_mirror_load_type.L(end),'VDS',DESIGN.spec.VDD/3,'VSB',0);
    if DESIGN.temp.VGS_3 > max_vgs || DESIGN.temp.VGS_3 < min_vgs
        fprintf("Error: these specs cannot be realized together, try changing one of these things: VDD, AO, GBW, CMIR, Technology\n"); 
        DESIGN.flag(6) = 0;
        return;
    else
    	DESIGN.temp.GDS_3 = DESIGN.temp.GDS_1;
    	DESIGN.temp.L_3_TEMP = lookupL(current_mirror_load_type, 15, DESIGN.temp.GDS_3 , DESIGN.spec.IBIAS/2, DESIGN.spec.VDD/3, 0, 1); 
        DESIGN.temp.GM_ID_3_MIN = lookup1(current_mirror_load_type,'GM_ID','VGS',DESIGN.temp.VGS_3,'VDS',DESIGN.spec.VDD/3,'VSB',0,'L',DESIGN.temp.L_3_TEMP); 
        
        kb = 1.38e-23;
        To = 300;
        gamma_1 = lookup1(input_pair_type,'STH_GM','L',DESIGN.temp.L_1,'VGS',DESIGN.temp.VGS_1,'VDS',DESIGN.spec.VDD/3,'VSB',0) / (4 * kb * To);
        Vnin = sqrt(DESIGN.spec.VNOUTRMS ^ 2 * 4 * DESIGN.spec.CL / DESIGN.temp.GM_1);
        % Find the combination of gamma*GM that meets the spec
        gammaxGM_temp = (Vnin^2 * DESIGN.temp.GM_1 / (8*kb*To) - gamma_1) * DESIGN.temp.GM_1;
        GM_ID_temp = (5:0.1:15)';
        gamma_temp = lookup1(current_mirror_load_type,'STH_GM','GM_ID',GM_ID_temp,'L',DESIGN.temp.L_3_TEMP) / (4 * kb * To);
        index_temp = find((gamma_temp .* GM_ID_temp) * (DESIGN.spec.IBIAS/2) < gammaxGM_temp,1,'last');
        if isempty(index_temp)
            fprintf("Error: current mirror load transistors can not be realized, try relaxing the noise spec\n");
            DESIGN.flag(6) = 0;
            return;
        else
            DESIGN.temp.GM_ID_3_MAX = GM_ID_temp(index_temp);
            if DESIGN.temp.GM_ID_3_MAX < DESIGN.temp.GM_ID_3_MIN
                fprintf("Error: current mirror load transistors can not be realized, try relaxing the noise spec\n");
                DESIGN.flag(6) = 0;
                return;
            else
                DESIGN.temp.GM_ID_3 = (DESIGN.temp.GM_ID_3_MAX + DESIGN.temp.GM_ID_3_MIN) / 2; 
                DESIGN.temp.GM_3 = DESIGN.temp.GM_ID_3 * (DESIGN.spec.IBIAS/2);
            end
        end
    end
    DESIGN.flag(6) = 1;
end

if DESIGN.spec.CMRR ~= -1 && DESIGN.flag(6) == 1 && DESIGN.flag(7) == -1
    eval(['cd ' DESIGN.file(1).folder]); % change directory to the technology files path
    load(DESIGN.file(1).name); % load tech files
    load(DESIGN.file(2).name);
    if DESIGN.spec.CMIR_HIGH + DESIGN.spec.CMIR_LOW >= DESIGN.spec.VDD
        tail_current_source_type = nch;
        DESIGN.temp.VDSAT_5_MAX = DESIGN.spec.CMIR_LOW - DESIGN.temp.VGS_1;
    else
        tail_current_source_type = pch;
        DESIGN.temp.VDSAT_5_MAX = double(solve((DESIGN.spec.CMIR_HIGH == DESIGN.spec.VDD - DESIGN.temp.VGS_1 - x), x));
    end
    syms x;
    DESIGN.temp.GDS_5 = double(solve((DESIGN.temp.GM_1 / (1 + DESIGN.temp.GM_1 * 2/x) * 1/DESIGN.temp.GM_3 == DESIGN.spec.AO/DESIGN.spec.CMRR), x));
    DESIGN.temp.L_5_TEMP = lookupL(tail_current_source_type, 15, DESIGN.temp.GDS_5, DESIGN.spec.IBIAS, DESIGN.spec.VDD/3, 0, 1);
    VGS_temp = lookupVGS(tail_current_source_type,'GM_ID',15,'L',DESIGN.temp.L_5_TEMP,'VDS',DESIGN.spec.VDD/3,'VSB',0);
    DESIGN.temp.VDSAT_5_TEMP_MIN = lookup1(tail_current_source_type,'VDSAT','L',DESIGN.temp.L_5_TEMP,'VGS',VGS_temp,'VDS',DESIGN.spec.VDD/3,'VSB',0);
    VDSATmargin = 10e-3;
    if DESIGN.temp.VDSAT_5_TEMP_MIN - VDSATmargin > DESIGN.temp.VDSAT_5_MAX
       fprintf("Error: the current source transistors can not be realized, try relaxing the CMRR spec\n"); 
       DESIGN.flag(7) = 0;
       return;
    end
    DESIGN.flag(7) = 1;
end

if DESIGN.spec.VDD ~= -1 && DESIGN.flag(8) == -1
    if DESIGN.spec.VDD <= 0
        fprintf("Error: VDD must be a positive number\n");
        DESIGN.flag(8) = 0;
        return;
    end
   DESIGN.flag(8) = 1; 
end