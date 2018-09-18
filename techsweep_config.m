% Configuration for techsweep_spectre_run.m
% Boris Murmann, Stanford University
% Tested with MMSIM12.11.134
% September 12, 2017
% Edited by Karim Tera, ASU
% On September 18, 2018

function c = techsweep_config

% Models and file paths
% c.modelfile = '"/home/cadence/Downloads/ptm_180nm_bsim3.txt"';
c.modelinfo = 'PTM 180nm CMOS, BSIM3v3';
c.corner = 'NOM';
c.temp = 300;
c.modeln = 'nmos';
c.modelp = 'pmos';
c.savefilen = 'n_xxx_YYY';
c.savefilep = 'p_xxx_YYY';
c.simcmd = '/usr/local/cadence/MMSIM141/bin/spectre -64 techsweep.scs'; 
c.outfile = '/home/cadence/Desktop/Project/web_matlab/lib/techsweep.raw'; % Must be set to techsweep_spectre_run.m directory
c.sweep = 'sweepvds_sweepvgs-sweep';
c.sweep_noise = 'sweepvds_noise_sweepvgs_noise-sweep';

% Sweep parameters
c.VGS_min = 0.2;
c.VDS_min = 0;
c.VSB_min = 0;
c.VGS_step = 25e-3;
c.VDS_step = 50e-3;
c.VSB_step = 100e-3;
c.VGS_max = 1;
c.VDS_max = 1;
c.VSB_max = 0.8;
c.VGS = c.VGS_min:c.VGS_step:c.VGS_max;
c.VDS = c.VDS_min:c.VDS_step:c.VDS_max;
c.VSB = c.VSB_min:c.VSB_step:c.VSB_max;
c.LENGTH = [(0.2:0.05:0.5) (0.6:0.1:2.0)];
c.WIDTH = 10;
c.NFING = 2;

% Variable mapping
c.outvars =            {'ID','VT','IGD','IGS','GM','GMB','GDS','CGG','CGS','CSG','CGD','CDG','CGB','CDD','CSS','VDSAT'};
c.n{1}= {'mn:ids','A',   [1    0    0     0     0    0     0     0     0     0     0     0     0     0     0      0    ]};
c.n{2}= {'mn:vth','V',   [0    1    0     0     0    0     0     0     0     0     0     0     0     0     0      0    ]};
c.n{3}= {'mn:igd','A',   [0    0    1     0     0    0     0     0     0     0     0     0     0     0     0      0    ]};
c.n{4}= {'mn:igs','A',   [0    0    0     1     0    0     0     0     0     0     0     0     0     0     0      0    ]};
c.n{5}= {'mn:gm','S',    [0    0    0     0     1    0     0     0     0     0     0     0     0     0     0      0    ]};
c.n{6}= {'mn:gmbs','S',  [0    0    0     0     0    1     0     0     0     0     0     0     0     0     0      0    ]};
c.n{7}= {'mn:gds','S',   [0    0    0     0     0    0     1     0     0     0     0     0     0     0     0      0    ]};
c.n{8}= {'mn:cgg','F',   [0    0    0     0     0    0     0     1     0     0     0     0     0     0     0      0    ]};
c.n{9}= {'mn:cgs','F',   [0    0    0     0     0    0     0     0    -1     0     0     0     0     0     0      0    ]};
c.n{10}={'mn:cgd','F',   [0    0    0     0     0    0     0     0     0     0    -1     0     0     0     0      0    ]};
c.n{11}={'mn:cgb','F',   [0    0    0     0     0    0     0     0     0     0     0     0    -1     0     0      0    ]};
c.n{12}={'mn:cdd','F',   [0    0    0     0     0    0     0     0     0     0     0     0     0     1     0      0    ]};
c.n{13}={'mn:cdg','F',   [0    0    0     0     0    0     0     0     0     0     0    -1     0     0     0      0    ]};
c.n{14}={'mn:css','F',   [0    0    0     0     0    0     0     0     0     0     0     0     0     0     1      0    ]};
c.n{15}={'mn:csg','F',   [0    0    0     0     0    0     0     0     0    -1     0     0     0     0     0      0    ]};
c.n{16}={'mn:cjd','F',   [0    0    0     0     0    0     0     0     0     0     0     0     0     1     0      0    ]};
c.n{17}={'mn:cjs','F',   [0    0    0     0     0    0     0     0     0     0     0     0     0     0     1      0    ]};
c.n{18}={'mn:vdsat','V', [0    0    0     0     0    0     0     0     0     0     0     0     0     0     0      1    ]};
%
%                      {'ID','VT','IGD','IGS','GM','GMB','GDS','CGG','CGS','CSG','CGD','CDG','CGB','CDD','CSS','VDSAT'};
c.p{1}= {'mp:ids','A',   [-1   0    0     0     0    0     0     0     0     0     0     0     0     0     0     0    ]};
c.p{2}= {'mp:vth','V',   [0   -1    0     0     0    0     0     0     0     0     0     0     0     0     0     0    ]};
c.p{3}= {'mp:igd','A',   [0    0   -1     0     0    0     0     0     0     0     0     0     0     0     0     0    ]};
c.p{4}= {'mp:igs','A',   [0    0    0    -1     0    0     0     0     0     0     0     0     0     0     0     0    ]};
c.p{5}= {'mp:gm','S',    [0    0    0     0     1    0     0     0     0     0     0     0     0     0     0     0    ]};
c.p{6}= {'mp:gmbs','S',  [0    0    0     0     0    1     0     0     0     0     0     0     0     0     0     0    ]};
c.p{7}= {'mp:gds','S',   [0    0    0     0     0    0     1     0     0     0     0     0     0     0     0     0    ]};
c.p{8}= {'mp:cgg','F',   [0    0    0     0     0    0     0     1     0     0     0     0     0     0     0     0    ]};
c.p{9}= {'mp:cgs','F',   [0    0    0     0     0    0     0     0    -1     0     0     0     0     0     0     0    ]};
c.p{10}={'mp:cgd','F',   [0    0    0     0     0    0     0     0     0     0    -1     0     0     0     0     0    ]};
c.p{11}={'mp:cgb','F',   [0    0    0     0     0    0     0     0     0     0     0     0    -1     0     0     0    ]};
c.p{12}={'mp:cdd','F',   [0    0    0     0     0    0     0     0     0     0     0     0     0     1     0     0    ]};
c.p{13}={'mp:cdg','F',   [0    0    0     0     0    0     0     0     0     0     0    -1     0     0     0     0    ]};
c.p{14}={'mp:css','F',   [0    0    0     0     0    0     0     0     0     0     0     0     0     0     1     0    ]};
c.p{15}={'mp:csg','F',   [0    0    0     0     0    0     0     0     0    -1     0     0     0     0     0     0    ]};
c.p{16}={'mp:cjd','F',   [0    0    0     0     0    0     0     0     0     0     0     0     0     1     0     0    ]};
c.p{17}={'mp:cjs','F',   [0    0    0     0     0    0     0     0     0     0     0     0     0     0     1     0    ]};
c.p{18}={'mp:vdsat','V', [0    0    0     0     0    0     0     0     0     0     0     0     0     0     0    -1    ]};
%
c.outvars_noise = {'STH','SFL'};
c.n_noise{1}= {'mn:id', ''};
c.n_noise{2}= {'mn:fn', ''};
%
c.p_noise{1}= {'mp:id', ''};
c.p_noise{2}= {'mp:fn', ''};



%% Writing the netlist
% The netlist has mosfets with constant Width = c.WIDTH, and length = parameter written in 'techsweep_param.scs'
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
'//techsweep.scs \n'...
'simulator lang=spectre \n'...
'include "techsweep_params.scs" \n']);

netlist = [netlist to_include];

netlist_temp = sprintf([...
'save mn \n'...
'save mp \n'...
'parameters gs=0 ds=0 \n'...
'vnoi     (vx  0)         vsource dc=0  \n'...
'vdsn     (vdn vx)        vsource dc=ds  \n'...
'vgsn     (vgn 0)         vsource dc=gs  \n'...
'vbsn     (vbn 0)         vsource dc=-sb \n'...
'vdsp     (vdp vx)        vsource dc=-ds \n'...
'vgsp     (vgp 0)         vsource dc=-gs \n'...
'vbsp     (vbp 0)         vsource dc=sb  \n'...
'\n']); % adding the voltage sources to the netlist

netlist = [netlist netlist_temp]; % concatenate

netlist = addMOS_techSWEEP(netlist,nmos_temp,'vdn','vgn','0','vbn',c.WIDTH); % add nmos to the netlist
netlist = addMOS_techSWEEP(netlist,pmos_temp,'vdp','vgp','0','vbp',c.WIDTH); % add pmos to the netlist

netlist_temp = sprintf([...
'\n'...
'simOptions options gmin=1e-13 reltol=1e-4 vabstol=1e-6 iabstol=1e-10 temp=%d tnom=27 rawfmt=psfbin rawfile="./techsweep.raw" \n'...
'sweepvds sweep param=ds start=%d stop=%d step=%d { \n'...
'   sweepvgs dc param=gs start=%d stop=%d step=%d \n'...
'}\n'...
'sweepvds_noise sweep param=ds start=%d stop=%d step=%d { \n'...
'   sweepvgs_noise noise freq=1 oprobe=vnoi param=gs start=%d stop=%d step=%d \n'...
'}\n'...
],c.temp-273, ...
c.VDS_min, c.VDS_max, c.VDS_step, ...
c.VGS_min, c.VGS_max, c.VGS_step, ...
c.VDS_min, c.VDS_max, c.VDS_step, ...
c.VGS_min, c.VGS_max, c.VGS_step); % adding the analysis to the netlist

netlist = [netlist netlist_temp]; % concatenate


% H: modified the above lines to include min boundaries: start=%d in the sweep
% Also VDS and VGS lines were flipped in Murmann's code
% Note that sweeping length and VSB is done in a loop in the _run file

% Write netlist
fid = fopen('techsweep.scs', 'w');
fprintf(fid, netlist);
fclose(fid);

return
