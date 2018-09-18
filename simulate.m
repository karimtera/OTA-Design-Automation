function DESIGN=simulate(DESIGN)
% this function simulates a given DESIGN of 5T OTA
% using spectre simulator

for i=1:11
   if ~DESIGN.flag(i)
       return;
   end
end

%% Simulation

c.modelfile = '"/home/cadence/Desktop/Project/web_matlab/lib/ptm_180nm_bsim3.txt"';
c.modelinfo = 'PTM 180nm CMOS, BSIM3v3';
c.corner = 'NOM';
c.temp = 300;
c.simcmd = '/usr/local/cadence/MMSIM141/bin/spectre -64 ota_5t_tb.scs';
%% Determining the transistors types

if DESIGN.spec.CMIR_HIGH + DESIGN.spec.CMIR_LOW >= DESIGN.spec.VDD
    input_pair_type = 'nch';
    connect_vdd_to = '0';
    connect_ground_to = 'vdd!';
    idc_from = 'vdd!'; 
    idc_to = 'net012';
else
    input_pair_type = 'pch';
    connect_vdd_to = 'vdd!';
    connect_ground_to = '0';
    idc_from = 'net012';
    idc_to = '0';
end
%% Creating netlist

% first the user is asked to make a simple schematic using a specific
% technology, this schematic should contain:
% 1) a nmos & a pmos transistor 
% 2) for the nmos: 
%       name = 'MN'
%       length = 'L'
%       width = 'W'
% 3) for the pmos: 
%       name = 'MP'
%       length = 'L'
%       width = 'W'
% 4) generate a netlist, rename it with 'netlist'.
% 5) move it to the working directory.
% 6) at least run a dc simulation.
if ~DESIGN.netlist % if user's netlist is not found, terminate
   return;
end
user_netlist = fileread('netlist'); % reads the user's netlist
first = regexp(user_netlist,'include '); % finds all the occurances of the 2nd paramenter inside the 1st one.
nmos_name = 'MN'; % NMOS name
pmos_name = 'MP'; % PMOS name
nmos_position = regexp(user_netlist,nmos_name); % searchs for NMOS name in the netlist
pmos_position = regexp(user_netlist,pmos_name); % searchs for PMOS name in the netlist
to_include = user_netlist(first(1):nmos_position-1); % taking the block of the include commands from in the netlist

nmos_temp = user_netlist(nmos_position:pmos_position-1); % taking the block of the nmos from the netlist
last_position_for_pmos = regexp(user_netlist,'simulatorOptions'); % determines the last char position in the pmos block
pmos_temp = user_netlist(pmos_position:last_position_for_pmos-1); % taking the block of the pmos from the netlist

netlist = sprintf([...
'// Generated for: spectre\n'...
'// Generated on: Jul 30 08:16:04 2018\n'...
'// Design library name: test\n'...
'// Design cell name: tstbench\n'...
'// Design view name: schematic\n'...
'simulator lang=spectre\n'...
'global 0 vdd!\n'...
'parameters W6=%0.2fe-6 L6=%0.2fe-6 L5=%0.2fe-6 W5=%0.2fe-6 L2=%0.2fe-6 \\\\\n'...
'    W2=%0.2fe-6 L1=%0.2fe-6 W1=%0.2fe-6 W4=%0.2fe-6 L4=%0.2fe-6 L3=%0.2fe-6 \\\\\n'...
'    W3=%0.2fe-6 IB=%d CL=%d VDD=%0.2f VICM=%0.2f\n'...
],DESIGN.M(6).W,DESIGN.M(6).L,DESIGN.M(5).L,DESIGN.M(5).W,DESIGN.M(2).L,DESIGN.M(2).W,DESIGN.M(1).L,DESIGN.M(1).W,DESIGN.M(4).W,DESIGN.M(4).L,DESIGN.M(3).L,DESIGN.M(3).W,DESIGN.spec.IBIAS/2,DESIGN.spec.CL,DESIGN.spec.VDD,DESIGN.spec.VICM);
% the pervious function begins writing the new netlist, by writing some
% general information then declares the design parameters

netlist = [netlist to_include]; % concatenates the include blocks to the new netlist

subcircuit = 'subckt tstfd IBIAS VDD VINN VINP VOUT ground'; % subckt declaration 
netlist = [netlist subcircuit  newline];  % concatenates the line that defines a subckt in cadence to the new netlist

if input_pair_type == 'nch'
    netlist = addMOS(netlist,'1',nmos_temp,'net5','VINP','net011','net011'); % adds nmos or pmos to the netlist
    netlist = addMOS(netlist,'2',nmos_temp,'VOUT','VINN','net011','net011');
    netlist = addMOS(netlist,'3',pmos_temp,'net5','net5','ground','ground');
    netlist = addMOS(netlist,'4',pmos_temp,'VOUT','net5','ground','ground');
    netlist = addMOS(netlist,'5',nmos_temp,'net011','IBIAS','VDD','VDD');
    netlist = addMOS(netlist,'6',nmos_temp,'IBIAS','IBIAS','VDD','VDD');
else
    netlist = addMOS(netlist,'1',pmos_temp,'net5','VINP','net011','net011');
    netlist = addMOS(netlist,'2',pmos_temp,'VOUT','VINN','net011','net011');
    netlist = addMOS(netlist,'3',nmos_temp,'net5','net5','ground','ground');
    netlist = addMOS(netlist,'4',nmos_temp,'VOUT','net5','ground','ground');
    netlist = addMOS(netlist,'5',pmos_temp,'net011','IBIAS','VDD','VDD');
    netlist = addMOS(netlist,'6',pmos_temp,'IBIAS','IBIAS','VDD','VDD');
end

connections_and_analysis = sprintf([...
'ends tstfd\n'...
'// End of subcircuit definition.\n'...
'\n'...
'// Library name: test\n'...
'// Cell name: tstbench\n'...
'// View name: schematic\n'...
'I0 (net012 %s net02 net06 vout %s) tstfd\n'...
'IPRB0 (net02 vout) iprobe\n'...
'V3 (net06 0) vsource dc=VICM mag=1 type=dc\n'...
'V0 (vdd! 0) vsource dc=VDD type=dc\n'...
'C0 (vout 0) capacitor c=CL\n'...
'I7 (%s %s) isource dc=IB type=dc\n'...
'simulatorOptions options reltol=1e-3 vabstol=1e-6 iabstol=1e-12 temp=27 \\\\\n'...
'    tnom=27 scalem=1.0 scale=1.0 gmin=1e-12 rforce=1 maxnotes=5 maxwarns=5 \\\\\n'...
'    digits=5 cols=80 pivrel=1e-3 sensfile="../psf/sens.output" \\\\\n'...
'    checklimitdest=psf \n'...
'dcOp dc write="spectre.dc" maxiters=150 maxsteps=10000 annotate=status\n'...
'dcOpInfo info what=oppoint where=rawfile\n'...
'ac ac start=10 stop=10G dec=10 annotate=status \n'...
'stb stb start=10 stop=10G dec=10 probe=IPRB0 annotate=status \n'...
'modelParameter info what=models where=rawfile\n'...
'element info what=inst where=rawfile\n'...
'outputParameter info what=output where=rawfile\n'...
'designParamVals info what=parameters where=rawfile\n'...
'primitives info what=primitives where=rawfile\n'...
'subckts info what=subckts where=rawfile\n'...
'save vout \n'...
'saveOptions options save=allpub\n'],connect_vdd_to,connect_ground_to...
,idc_from,idc_to);
% the previous char array contains connections of the circuit blocks and
% also the analysis to be runned by cadence
netlist = [netlist connections_and_analysis]; % concatenates the connections&analysis part to the new netlist

netlist = strrep(netlist, '\','\\'); % the special character '\' is interpreted as an escape character in matlab, so needed to double it as the documentation says
netlist = strrep(netlist, '\\\\','\\'); % but there were already '\\' in the netlist, so some '\\' turned to '\\\\', this line reverses this operation.

%% Simulation netlist

% Write netlist
fid = fopen('ota_5t_tb.scs', 'w'); % open a file to write in it
fprintf(fid, netlist); % write the new netlist
fclose(fid); % close it

% pause for 1 second
pause(1)
        
% Run simulator
[status,result] = system(c.simcmd);
if(status)
    disp('Simulation did not run properly.')
    return;
end 

DESIGN.sim.LG = cds_srr('ota_5t_tb.raw','stb-stb','loopGain');
% sim.MAGED = cds_srr('ota_5t_tb.raw','stb-stb','vout','gainBwProd');
DESIGN.sim.LGmag = abs(DESIGN.sim.LG.LOOPGAIN);
DESIGN.sim.LGmagdB = 20*log10(DESIGN.sim.LGmag);
DESIGN.sim.freq = DESIGN.sim.LG.freq;
DESIGN.sim.Ao = DESIGN.sim.LGmag(1);
DESIGN.sim.AodB = DESIGN.sim.LGmagdB(1);
DESIGN.sim.BW = interp1(DESIGN.sim.LGmagdB, DESIGN.sim.freq, DESIGN.sim.AodB - 3);
DESIGN.sim.GBW = DESIGN.sim.Ao * DESIGN.sim.BW;
DESIGN.sim.UGF = cds_srr('ota_5t_tb.raw','stb-margin.stb','phaseMarginFreq');
DESIGN.sim.PM = cds_srr('ota_5t_tb.raw','stb-margin.stb','phaseMargin');
DESIGN.sim.GM = (cds_srr('ota_5t_tb.raw','dcOpInfo-info','I0.M1:gm') + cds_srr('ota_5t_tb.raw','dcOpInfo-info','I0.M2:gm')) / 2;
DESIGN.sim.CLeffLG = DESIGN.sim.GM / 2 / pi / DESIGN.sim.GBW;
DESIGN.sim.VOUT = cds_srr('ota_5t_tb.raw','ac-ac','vout');
DESIGN.sim.VOUTmag = abs(DESIGN.sim.VOUT.V);
DESIGN.sim.AoCL = DESIGN.sim.VOUTmag(1);
DESIGN.sim.BWCL = interp1(DESIGN.sim.VOUTmag,DESIGN.sim.VOUT.freq,DESIGN.sim.AoCL/sqrt(2));
DESIGN.sim.GBWCL = DESIGN.sim.AoCL * DESIGN.sim.BWCL;
DESIGN.sim.CLeffCL = DESIGN.sim.GM / 2 / pi / DESIGN.sim.GBWCL;
DESIGN.sim.IIN = cds_srr('ota_5t_tb.raw','ac-ac','V3:p');
DESIGN.sim.CIN = abs(imag(DESIGN.sim.IIN.I)) / 2 / pi ./ DESIGN.sim.IIN.freq;
DESIGN.sim.CINo = DESIGN.sim.CIN(1);
% sim
Msim(1).CGS = abs(cds_srr('ota_5t_tb.raw','dcOpInfo-info','I0.M1:cgs'));
Msim(1).CGD = abs(cds_srr('ota_5t_tb.raw','dcOpInfo-info','I0.M1:cgd'));
Msim(1).CGS * 3/4 / DESIGN.sim.Ao + Msim(1).CGD;



