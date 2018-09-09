function model=setSpec(model,varargin)
% this function sets the specs of the model  
% in order for this fuction to work correctly the user should pass one of
% these parameters:
% 'VDD','IBIAS','CL','CIN','AO','CMRR','CMIR_HIGH','CMIR_LOW','VNOUTRMS','VICM','GBW'.
% some special codes you can enter:
% 1) if you don't care about a parameter, enter -1
% 2) if you want to optimize on this parameter, enter -2

for i=1:11
   if model.flag(i) == -2
       return;
   end
end

param = {'VDD','IBIAS','CL','CIN','AO','CMRR','CMIR_HIGH','CMIR_LOW','VNOUTRMS','VICM','GBW'};

if isempty(find(strcmp(param,varargin{1}),1)) % if the spec is not found in the parameters cell, terminate
    fprintf('Error: this spec %s is not defined, please read setSpec help\n',varargin{1});
    return;
end

eval(['model.spec.' varargin{1} '=' num2str(varargin{2}) ';']); % add the required spec

if model.spec.CL ~= -1 && model.spec.IBIAS ~= -1 && model.spec.GBW ~= -2 && model.spec.GBW~=-1 && ~model.flag(1) 
	model.temp.GM_1 = 2 * pi * model.spec.GBW * model.spec.CL ;
    model.temp.GM_ID_1 = model.temp.GM_1 / (model.spec.IBIAS/2);
    if model.temp.GM_ID_1 < 5 || model.temp.GM_ID_1 > 16
        fprintf('Error: this GBW can not be realized given ID and CL\n'); 
        model.flag(1) = -2;
        return;
    end
    model.flag(1) = 1;
    
end

if model.spec.CMIR_LOW ~= -1 && ~model.flag(2)
    if model.spec.CMIR_LOW < 0 
        fprintf("Error: the CMIR should at least start from 0 voltage\n");
        model.flag(2) = -2;
        return;
    end
    model.flag(2) = 1;
end

if model.spec.CMIR_HIGH ~= -1 && ~model.flag(3)
    if model.spec.CMIR_HIGH < 0
        fprintf("Error: the CMIR should at least start from 0 voltage\n");
        model.flag(3) = -2;
        return;
    end
    model.flag(3) = 1;
end


if model.flag(2) && model.flag(3) && model.spec.VDD ~= -1 && ~model.flag(4)
    if model.spec.CMIR_HIGH > model.spec.VDD
        fprintf("Error: the CMIR should at most end at VDD\n");
        model.flag(4) = -2;
        return;
    end
    if model.spec.CMIR_HIGH < model.spec.CMIR_LOW
        fprintf("Error: the (end)CMIR is not correctly defined\n");
        model.flag(4) = -2;
        return;
    end
    model.flag(4) = 1;
end

if model.spec.AO ~= -1 && model.flag(1) && model.flag(4) && ~model.flag(5)
    eval(['cd ' model.file(1).folder]); % change directory to the technology files path
    load(model.file(1).name); % load tech files
    load(model.file(2).name);
    model.temp.GDS_1 = model.temp.GM_1 / model.spec.AO / 2;
    model.temp.GM_GDS_1 = model.temp.GM_1 / model.temp.GDS_1;
    if model.spec.CMIR_HIGH + model.spec.CMIR_LOW >= model.spec.VDD
        input_pair_type = nch;
    else
        input_pair_type = pch;
    end
    min_gain = lookup1(input_pair_type,'GM_GDS','GM_ID',5,'L',input_pair_type.L(1),'VDS',model.spec.VDD/3,'VSB',0);
    max_gain = lookup1(input_pair_type,'GM_GDS','GM_ID',15,'L',input_pair_type.L(end),'VDS',model.spec.VDD/3,'VSB',0);
    if model.temp.GM_GDS_1 > max_gain || model.temp.GM_GDS_1 < min_gain
       fprintf("Error: this gain cannot be realized given the technology\n"); 
       model.flag(5) = -2;
       return;
    else
        model.temp.L_1 = lookupL(input_pair_type,model.temp.GM_ID_1 ,model.temp.GDS_1 ,model.spec.IBIAS/2,model.spec.VDD/3,0,1);
        model.temp.VGS_1 = lookupVGS(input_pair_type,'GM_ID',model.temp.GM_ID_1,'L',model.temp.L_1,'VDS',model.spec.VDD/3,'VSB',0);
        model.temp.VDSAT_1 = lookup1(input_pair_type,'VDSAT','L',model.temp.L_1,'VGS',model.temp.VGS_1,'VDS',model.spec.VDD/3,'VSB',0);
    end
    model.flag(5) = 1;
end


if model.flag(4) && model.flag(5) && ~model.flag(6)
    eval(['cd ' model.file(1).folder]); % change directory to the technology files path
    load(model.file(1).name); % load tech files
    load(model.file(2).name);
    if model.spec.CMIR_HIGH + model.spec.CMIR_LOW >= model.spec.VDD
        input_pair_type = nch;
        current_mirror_load_type = pch;
        model.temp.VGS_3 = model.spec.VDD - model.spec.CMIR_HIGH - model.temp.VDSAT_1 + model.temp.VGS_1;
    else
        input_pair_type = pch;
        current_mirror_load_type = nch;
    	model.temp.VGS_3 = model.spec.CMIR_LOW + model.temp.VGS_1 - model.temp.VDSAT_1;
    end
    max_vgs = lookupVGS(current_mirror_load_type,'GM_ID',5,'L',current_mirror_load_type.L(1),'VDS',model.spec.VDD/3,'VSB',0);
    min_vgs = lookupVGS(current_mirror_load_type,'GM_ID',15,'L',current_mirror_load_type.L(end),'VDS',model.spec.VDD/3,'VSB',0);
    if model.temp.VGS_3 > max_vgs || model.temp.VGS_3 < min_vgs
        fprintf("Error: these specs cannot be realized together, try changing one of these things: VDD, AO, GBW, CMIR, Technology\n"); 
        model.flag(6) = -2;
        return;
    else
    	model.temp.GDS_3 = model.temp.GDS_1;
    	model.temp.L_3_TEMP = lookupL(current_mirror_load_type, 15, model.temp.GDS_3 , model.spec.IBIAS/2, model.spec.VDD/3, 0, 1); 
        model.temp.GM_ID_3_MIN = lookup1(current_mirror_load_type,'GM_ID','VGS',model.temp.VGS_3,'VDS',model.spec.VDD/3,'VSB',0,'L',model.temp.L_3_TEMP); 
        
        kb = 1.38e-23;
        To = 300;
        gamma_1 = lookup1(input_pair_type,'STH_GM','L',model.temp.L_1,'VGS',model.temp.VGS_1,'VDS',model.spec.VDD/3,'VSB',0) / (4 * kb * To);
        Vnin = sqrt(model.spec.VNOUTRMS ^ 2 * 4 * model.spec.CL / model.temp.GM_1);
        % Find the combination of gamma*GM that meets the spec
        gammaxGM_temp = (Vnin^2 * model.temp.GM_1 / (8*kb*To) - gamma_1) * model.temp.GM_1;
        GM_ID_temp = (5:0.1:15)';
        gamma_temp = lookup1(current_mirror_load_type,'STH_GM','GM_ID',GM_ID_temp,'L',model.temp.L_3_TEMP) / (4 * kb * To);
        index_temp = find((gamma_temp .* GM_ID_temp) * (model.spec.IBIAS/2) < gammaxGM_temp,1,'last');
        if isempty(index_temp)
            fprintf("Error: current mirror load transistors can not be realized, try relaxing the noise spec\n");
            model.flag(6) = -2;
            return;
        else
            model.temp.GM_ID_3_MAX = GM_ID_temp(index_temp);
            if model.temp.GM_ID_3_MAX < model.temp.GM_ID_3_MIN
                fprintf("Error: current mirror load transistors can not be realized, try relaxing the noise spec\n");
                model.flag(6) = -2;
                return;
            else
                model.temp.GM_ID_3 = (model.temp.GM_ID_3_MAX + model.temp.GM_ID_3_MIN) / 2; 
                model.temp.GM_3 = model.temp.GM_ID_3 * (model.spec.IBIAS/2);
            end
        end
    end
    model.flag(6) = 1;
end

if model.spec.CMRR ~= -1 && model.flag(6) && ~model.flag(7)
    eval(['cd ' model.file(1).folder]); % change directory to the technology files path
    load(model.file(1).name); % load tech files
    load(model.file(2).name);
    if model.spec.CMIR_HIGH + model.spec.CMIR_LOW >= model.spec.VDD
        tail_current_source_type = nch;
        model.temp.VDSAT_5_MAX = model.spec.CMIR_LOW - model.temp.VGS_1;
    else
        tail_current_source_type = pch;
        model.temp.VDSAT_5_MAX = double(solve((model.spec.CMIR_HIGH == model.spec.VDD - model.temp.VGS_1 - x), x));
    end
    syms x;
    model.temp.GDS_5 = double(solve((model.temp.GM_1 / (1 + model.temp.GM_1 * 2/x) * 1/model.temp.GM_3 == model.spec.AO/model.spec.CMRR), x));
    model.temp.L_5_TEMP = lookupL(tail_current_source_type, 15, model.temp.GDS_5, model.spec.IBIAS, model.spec.VDD/3, 0, 1);
    VGS_temp = lookupVGS(tail_current_source_type,'GM_ID',15,'L',model.temp.L_5_TEMP,'VDS',model.spec.VDD/3,'VSB',0);
    model.temp.VDSAT_5_TEMP_MIN = lookup1(tail_current_source_type,'VDSAT','L',model.temp.L_5_TEMP,'VGS',VGS_temp,'VDS',model.spec.VDD/3,'VSB',0);
    VDSATmargin = 10e-3;
    if model.temp.VDSAT_5_TEMP_MIN - VDSATmargin > model.temp.VDSAT_5_MAX
       fprintf("Error: the current source transistors can not be realized, try relaxing the CMRR spec\n"); 
       model.flag(7) = -2;
       return;
    end
    model.flag(7) = 1;
end

if model.spec.VDD ~= -1 && ~model.flag(8)
    if model.spec.VDD <= 0
        fprintf("Error: VDD must be a positive number\n");
        model.flag(8) = -2;
        return;
    end
   model.flag(8) = 1; 
end
