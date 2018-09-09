function simResults(model)
% this function plots the model.simulation results

for i=1:11
   if model.flag(i) == -2
       return;
   end
end

if model.mode=='5T_OTA'
    T = table(model.sim.AodB,model.sim.BW,model.sim.GBW,model.sim.PM,model.sim.AoCL,model.sim.BWCL,model.sim.GBWCL,'RowNames',{'5T_OTA'},'VariableNames',{'OPENLOOP_GAIN_dB' 'OPENLOOP_BW' 'OPENLOOP_GAINBW' 'PHASE_MARGIN' 'CLOSEDLOOP_GAIN_dB' 'CLOSEDLOOP_BW' 'CLOSEDLOOP_GAINBW'})
    figure 
    subplot(2,1,1)
    plot(log10(model.sim.freq),model.sim.LGmagdB);
    title('LOOP GAIN (dB)');
    subplot(2,1,2)
    plot(log10(model.sim.freq),angle(model.sim.LG.LOOPGAIN)*180/pi);
    title('OPEN LOOP GAIN (PHASE)');
end
