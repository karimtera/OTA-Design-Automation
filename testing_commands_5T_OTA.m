close all;
clear all;
clc;
%% LOADING TECHNOLOGY
% The user should provide the path of the code library
% Also it validates the path, in order to prevent run time errors
Tech = checkTechAndReturnPath('/home/cadence/Desktop/Project/web_matlab/lib'); % set tech path
if ~Tech(1).state % if technology files couldn't be loaded, then  terminate
    return 
end
%% DESIGN MODE SETTING
% There are three different modes:
% 1) 5T_OTA1
% 2) FOLDED_DT
% 3) FOLDED_CT
% also we perform a check on the mode given by the user
OTA1 = setDesignMode('5T_OTA');

%% SPECS SETTING
% Here the user inputs the required specs
OTA1 = setSpec(OTA1,'VDD',1.8);
OTA1 = setSpec(OTA1,'IBIAS',20e-6);
OTA1 = setSpec(OTA1,'CL',5e-12);
OTA1 = setSpec(OTA1,'CIN',10e-15);
OTA1 = setSpec(OTA1,'AO',10^(32/20)); % 29dB --> 38dB
OTA1 = setSpec(OTA1,'CMRR',10^(70/20));
OTA1 = setSpec(OTA1,'CMIR_HIGH',1.7);
OTA1 = setSpec(OTA1,'CMIR_LOW',0.9);
OTA1 = setSpec(OTA1,'VNOUTRMS',50e-6);
OTA1 = setSpec(OTA1,'VICM',1.3);
OTA1 = setSpec(OTA1,'GBW',5e6);

%% CHECKING SPECS SETTING 
% checks the ability of realizing the current specs given the technology
if ~checkSpec(OTA1)
    return 
end

%% DESIGNING SECTION
% This single function designs the required model using gm/ID methodology
% and returns a table containing all the transistors parameters
[OTA1_Design,OTA1] = design(OTA1,Tech);
printTable(OTA1_Design,OTA1.Mode);

%% SIMULATING SECTION
% Function simulate(design,specs) opens candence spectre, runs the simulation
% and returns the simulation results in a struct
% after that, we also perform a check to see if the design contains errors
OTA1_Sim = simulate(OTA1_Design,OTA1);


%% PLOTTING RESULTS
% Finally, we plot the simulation results
simResults(OTA1_Sim,OTA1.Mode);
