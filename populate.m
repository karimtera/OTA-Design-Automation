function MP = populate(GM_ID,L,ID, type, VDS, VSB)
% MP = populate(GM_ID,L,ID, type, VDS, VSB)
% Populate transistor parameters
% Return populated structure
% The following should be defined for M: ID, gm/ID, L
    
    % constants
    kb = 1.38e-23;
    To = 300;
    
    %MP.type = type.TYPE;
    
    MP.GM_ID = GM_ID;
    MP.L = L;
    MP.ID = ID;
    
    MP.VGS = lookupVGS(type,'GM_ID',GM_ID,'L',L,'VDS',VDS,'VSB',VSB);
    
    param = {'ID_W','GM_GDS','GM_CGG','VDSAT','VT'};
    param_w = {'GM','GDS','GMB','CGS','CDD','CGD'};

   
    MP.(param{1}) = lookup1(type,param{1},'L',L,'VGS',MP.VGS,'VDS',VDS,'VSB',VSB);
    MP.W = ID / MP.ID_W;

    for i = 2:length(param)
        MP.(param{i}) = lookup1(type,param{i},'L',L,'VGS',MP.VGS,'VDS',VDS,'VSB',VSB);
    end
      
    for i = 1:length(param_w)
        MP.(param_w{i}) = lookup1(type,param_w{i},'L',L,'VGS',MP.VGS,'VDS',VDS,'VSB',VSB) / type.W * MP.W;
    end
    
    MP.CDB = MP.CDD - MP.CGD;

    % Note that STH is generated for 10um width device, so you cannot get gamma by
    % dividing by GM. You must use the normalized version STH_GM
    MP.gamma = lookup1(type,'STH_GM','L',L,'VGS',MP.VGS,'VDS',VDS,'VSB',VSB) / (4 * kb * To);

end