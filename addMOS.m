function netlist = addMOS(netlist,NUMBER,MOS_TXT_BLOCK,DRAIN,GATE,SOURCE,BULK)
% returns a new netlist, with a MOSFET added
% 
% 
% 
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'DRAIN',DRAIN);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'GATE',GATE);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'SOURCE',SOURCE);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'BULK',BULK);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'L',['L' NUMBER]);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'W',['W' NUMBER]);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'MN',['M' NUMBER]);
MOS_TXT_BLOCK = strrep(MOS_TXT_BLOCK,'MP',['M' NUMBER]);

netlist = [netlist newline MOS_TXT_BLOCK];

