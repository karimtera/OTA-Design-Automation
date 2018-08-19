function simResults(sim,mode)
% this function plots the simulation results


if mode=='5T_OTA'
    T = table(sim.AodB,sim.BW,sim.GBW,sim.PM,sim.AoCL,sim.BWCL,sim.GBWCL,'RowNames',{'5T_OTA'},'VariableNames',{'OPENLOOP_GAIN_dB' 'OPENLOOP_BW' 'OPENLOOP_GAINBW' 'PHASE_MARGIN' 'CLOSEDLOOP_GAIN_dB' 'CLOSEDLOOP_BW' 'CLOSEDLOOP_GAINBW'})
    figure 
    subplot(2,1,1)
    plot(log10(sim.freq),sim.LGmagdB);
    title('LOOP GAIN (dB)');
    subplot(2,1,2)
    plot(log10(sim.freq),angle(sim.LG.LOOPGAIN)*180/pi);
    title('OPEN LOOP GAIN (PHASE)');
end
