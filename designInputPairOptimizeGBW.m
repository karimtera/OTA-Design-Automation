function M = designInputPairOptimizeGBW(type,ID,AO,VDS,CIN)
% this function returns a struct of transistor, containing its drain
% current, GM/ID , channel length.
% it chooses the maximum GM/ID that satisfy the CIN condition to maximize
% the GBW using binary search technique

GM_ID_temp = (5:0.1:20)';
GM_temp = GM_ID_temp * ID;
GDS_temp = GM_ID_temp * ID / 2 / AO;
L_temp=lookupL(type,GM_ID_temp,GDS_temp,ID,VDS,0,1);
cgs_temp = GM_temp ./ diag(lookup1(type,'GM_CGS','GM_ID',GM_ID_temp,'L',L_temp,'VDS',VDS));
cgd_temp = GM_temp ./ diag(lookup1(type,'GM_CGD','GM_ID',GM_ID_temp,'L',L_temp,'VDS',VDS));
cin_temp = cgs_temp * 3/4 / AO + cgd_temp;
index_temp = find(cin_temp < 0.9*CIN,1,'last');
    
%% Choosing an optimized length(L1,L2) to maximize GBW (using binary search)
start = 1; % defining the starting index of the search space 
en = index_temp; % defining the last index of the search space
while start < en % continue in searching while there number of elements in search space > 1
    mid = floor((start+en+1)/2); % pick an mid index inside the search space 
    M.GM_ID = GM_ID_temp(mid); 
    M.L = L_temp(mid);
    Vgs = lookupVGS(type,'GM_ID',M.GM_ID,'L',M.L,'VDS',VDS,'VSB',0);
    Vt = lookup1(type,'VT','L',M.L,'VGS',Vgs,'VDS',VDS,'VSB',0);
    if Vgs > Vt
        start = mid; % if this length is valid, discard all lengths before this length
    else
        en = mid-1;  % if this length is not valid, discard all lengths after this item
    end
end
% now mid contains the index of the last valid length
M.GM_ID = GM_ID_temp(mid);
M.L = L_temp(mid);
M.ID = ID;
