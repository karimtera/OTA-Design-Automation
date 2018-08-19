function model=setSpec(model,varargin)
% this function sets the specs of the model  
% in order for this fuction to work correctly the user should pass one of
% these parameters:
% 'VDD','IBIAS','CL','CIN','AO','CMRR','CMIR_HIGH','CMIR_LOW','VNOUTRMS','VICM','GBW'.
% some special codes you can enter:
% 1) if you don't care about a parameter, enter -1
% 2) if you want to optimize on this parameter, enter -2

param = {'VDD','IBIAS','CL','CIN','AO','CMRR','CMIR_HIGH','CMIR_LOW','VNOUTRMS','VICM','GBW'};

if isempty(find(strcmp(param,varargin{1}),1)) % if the spec is not found in the parameters cell, terminate
    fprintf('Error: this spec %s is not defined, please read setSpec help',varargin{1});
    return;
end

eval(['model.' varargin{1} '=' num2str(varargin{2}) ';']); % add the required spec
