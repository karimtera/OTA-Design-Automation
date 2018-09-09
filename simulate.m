function model=simulate(model)
% this function simulates a given model of 5T OTA
% using spectre simulator

for i=1:11
   if model.flag(i) == -2
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

if model.spec.CMIR_HIGH + model.spec.CMIR_LOW >= model.spec.VDD
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
% 1) create new library: 'test'
% 2) create new cell: 'tstbench'
% 3) a nmos & a pmos transistor connected together(gate --> gate, drain --> drain, so on...)
% 4) for the nmos: 
%       name = 'MN'
%       length = 'L'
%       width = 'W'
% 5) for the pmos: 
%       name = 'MP'
%       length = 'L'
%       width = 'W'
% 6) label the gate, drain, bulk, and source nodes as 'GATE','DRAIN','BULK', and 'SOURCE'
% respectively.
% 7) generate a netlist, rename it with 'netlist'.
% 8) move it to the working directory.
% 9) at least run a dc simulation.

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
],model.M(6).W,model.M(6).L,model.M(5).L,model.M(5).W,model.M(2).L,model.M(2).W,model.M(1).L,model.M(1).W,model.M(4).W,model.M(4).L,model.M(3).L,model.M(3).W,model.spec.IBIAS/2,model.spec.CL,model.spec.VDD,model.spec.VICM);
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

model.sim.LG = cds_srr('ota_5t_tb.raw','stb-stb','loopGain');
% sim.MAGED = cds_srr('ota_5t_tb.raw','stb-stb','vout','gainBwProd');
model.sim.LGmag = abs(model.sim.LG.LOOPGAIN);
model.sim.LGmagdB = 20*log10(model.sim.LGmag);
model.sim.freq = model.sim.LG.freq;
model.sim.Ao = model.sim.LGmag(1);
model.sim.AodB = model.sim.LGmagdB(1);
model.sim.BW = interp1(model.sim.LGmagdB, model.sim.freq, model.sim.AodB - 3);
model.sim.GBW = model.sim.Ao * model.sim.BW;
model.sim.UGF = cds_srr('ota_5t_tb.raw','stb-margin.stb','phaseMarginFreq');
model.sim.PM = cds_srr('ota_5t_tb.raw','stb-margin.stb','phaseMargin');
model.sim.GM = (cds_srr('ota_5t_tb.raw','dcOpInfo-info','I0.M1:gm') + cds_srr('ota_5t_tb.raw','dcOpInfo-info','I0.M2:gm')) / 2;
model.sim.CLeffLG = model.sim.GM / 2 / pi / model.sim.GBW;
model.sim.VOUT = cds_srr('ota_5t_tb.raw','ac-ac','vout');
model.sim.VOUTmag = abs(model.sim.VOUT.V);
model.sim.AoCL = model.sim.VOUTmag(1);
model.sim.BWCL = interp1(model.sim.VOUTmag,model.sim.VOUT.freq,model.sim.AoCL/sqrt(2));
model.sim.GBWCL = model.sim.AoCL * model.sim.BWCL;
model.sim.CLeffCL = model.sim.GM / 2 / pi / model.sim.GBWCL;
model.sim.IIN = cds_srr('ota_5t_tb.raw','ac-ac','V3:p');
model.sim.CIN = abs(imag(model.sim.IIN.I)) / 2 / pi ./ model.sim.IIN.freq;
model.sim.CINo = model.sim.CIN(1);
% sim
Msim(1).CGS = abs(cds_srr('ota_5t_tb.raw','dcOpInfo-info','I0.M1:cgs'));
Msim(1).CGD = abs(cds_srr('ota_5t_tb.raw','dcOpInfo-info','I0.M1:cgd'));
Msim(1).CGS * 3/4 / model.sim.Ao + Msim(1).CGD;
