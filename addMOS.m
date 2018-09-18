function netlist = addMOS(netlist,NUMBER,MOS_TXT_BLOCK,DRAIN,GATE,SOURCE,BULK)
% returns a new netlist, with a MOSFET added
% parameters explained: 
% 1) netlist: is the netlist to be edited
% 2) NUMBER: used to name the mosfet itself, and its lenght, width
% 3) MOS_TXT_BLOCK: a char array contains the mosfet template
% 4) DRAIN: a char array of the node's name connected to drain
% 5) GATE: a char array of the node's name connected to gate
% 6) SOURCE: a char array of the node's name connected to source
% 7) BULK: a char array of the node's name connected to bulk

%% Getting the nets names connected to the MOSFET

START = regexp(MOS_TXT_BLOCK,'(');
START = START(1);
END = regexp(MOS_TXT_BLOCK,')');
END = END(1);
SPACE = regexp(MOS_TXT_BLOCK,' ');
SPACE = SPACE(find( SPACE > START & SPACE < END)); % finds the spaces positions after '(' and before ')'
DRAIN_NODE = MOS_TXT_BLOCK(START+1:SPACE(1)-1); % the net name connected to the drain
GATE_NODE = MOS_TXT_BLOCK(SPACE(1)+1:SPACE(2)-1); % the net name connected to the gate
SOURCE_NODE = MOS_TXT_BLOCK(SPACE(2)+1:SPACE(3)-1); % the net name connected to the source
BULK_NODE = MOS_TXT_BLOCK(SPACE(3)+1:END-1); % the net name connected to the bulk

%% Adding the MOSFET

MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,DRAIN_NODE,DRAIN);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,GATE_NODE,GATE);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,SOURCE_NODE,SOURCE);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,BULK_NODE,BULK);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'L',['L' NUMBER]);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'W',['W' NUMBER]);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'MN',['M' NUMBER]);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'MP',['M' NUMBER]);

netlist = [netlist newline MOS_TXT_BLOCK];

