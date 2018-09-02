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

MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'DRAIN',DRAIN);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'GATE',GATE);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'SOURCE',SOURCE);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'BULK',BULK);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'L',['L' NUMBER]);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'W',['W' NUMBER]);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'MN',['M' NUMBER]);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'MP',['M' NUMBER]);

netlist = [netlist newline MOS_TXT_BLOCK];

