close all;
clear all;
clc;
%% LOADING TECHNOLOGY
% The user should provide the path of the code library
% Also it validates the path, in order to prevent run time errors
OTA1 = checkTechAndReturnPath('/home/cadence/Desktop/Project/web_matlab/lib'); % set tech path
if ~OTA1.file(1).state % if technology files couldn't be loaded, then  terminate
    return 
end
%% DESIGN MODE SETTING
% There are three different modes:
% 1) 5T_OTA1
% 2) FOLDED_DT
% 3) FOLDED_CT
% also we perform a check on the mode given by the user
OTA1 = setDesignMode(OTA1,'5T_OTA');

%% SPECS SETTING
% Here the user inputs the required specs
OTA1 = setSpec(OTA1,'VDD',1.8);
OTA1 = setSpec(OTA1,'IBIAS',20e-6);
OTA1 = setSpec(OTA1,'CL',5e-12);
OTA1 = setSpec(OTA1,'CIN',10e-15);
OTA1 = setSpec(OTA1,'AO',10^(32/20)); % 29dB --> 38dB
OTA1 = setSpec(OTA1,'CMRR',10^(70/20));
OTA1 = setSpec(OTA1,'CMIR_HIGH',1.6);
OTA1 = setSpec(OTA1,'CMIR_LOW',0.7);
OTA1 = setSpec(OTA1,'VNOUTRMS',50e-6);
OTA1 = setSpec(OTA1,'VICM',1.3);
OTA1 = setSpec(OTA1,'GBW',5e6);

%% DESIGNING SECTION
% This single function designs the required model using gm/ID methodology
% and returns a table containing all the transistors parameters
OTA1 = design(OTA1);
printTable(OTA1);

%% SIMULATING SECTION
% Function simulate(design,specs) opens candence spectre, runs the simulation
% and returns the simulation results in a struct
% after that, we also perform a check to see if the design contains errors
OTA1 = simulate(OTA1);


%% PLOTTING RESULTS
% Finally, we plot the simulation results
simResults(OTA1);
