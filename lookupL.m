function L = lookupL(type, GM_ID, GDS, ID, VDS, VSB, interp)
%L = lookupL(type, GM_ID, GDS, ID, VDS, VSB, interp)
% The choice of gm/ID is NOT arbitrary. It DOES affect the returned L.

% make first assumption for gm/ID to get L
GM = GM_ID .* ID;

% get intrinsic gain of input pair
% use lookup2 in mode 3 to get gain vs L and vs GM_ID
% The result from lookup2 is a matrix m x n, with m being the larger array
% (m > n)
gm_gds_temp = lookup1(type,'GM_GDS','GM_ID',GM_ID,'L',type.L,'VDS',VDS,'VSB',VSB);
% select the min L that meets the spec
gm_gds=GM./GDS;
if(interp ==1)
    % at every GM_ID, search for appropriate L
    for i=1:length(GM_ID)
        L(i) = interp1(gm_gds_temp(:,i),type.L,gm_gds(i));
    end
else
    L = type.L(find(gm_gds_temp > gm_gds, 1, 'first'));
end

if(isnan(L))
    L=[];
end

end