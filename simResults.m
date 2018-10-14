function simResults(DESIGN)
% this function plots the DESIGN.simulation results

for i=1:11
   if ~DESIGN.flag(i)
       return;
   end
end

if DESIGN.mode=='5T_OTA'
    T = table(DESIGN.sim.AodB,DESIGN.sim.BW,DESIGN.sim.GBW,DESIGN.sim.PM,DESIGN.sim.AoCL,DESIGN.sim.BWCL,DESIGN.sim.GBWCL,'RowNames',{'5T_OTA'},'VariableNames',{'OPENLOOP_GAIN_dB' 'OPENLOOP_BW' 'OPENLOOP_GAINBW' 'PHASE_MARGIN' 'CLOSEDLOOP_GAIN_dB' 'CLOSEDLOOP_BW' 'CLOSEDLOOP_GAINBW'})
    figure 
    subplot(2,1,1)
    plot(log10(DESIGN.sim.freq),DESIGN.sim.LGmagdB);
    title('LOOP GAIN (dB)');
    subplot(2,1,2)
    plot(log10(DESIGN.sim.freq),angle(DESIGN.sim.LG.LOOPGAIN)*180/pi);
    title('OPEN LOOP GAIN (PHASE)');
end
