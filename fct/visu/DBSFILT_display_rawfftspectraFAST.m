


function DBSFILT_display_rawfftspectraFAST(Spikes,FlagSpikes,Fmin,Fmax,str_title)


fig=figure;
set(fig, 'color',get(0,'defaultUicontrolBackgroundColor'));


if(FlagSpikes==1)
    hold on
    plot(Spikes(1,:),Spikes(2,:),'r','LineWidth',2);
    plot(Spikes(1,:),Spikes(2,:).*not(Spikes(6,:))+Spikes(3,:).*Spikes(6,:),'Color',[0.2 0.4 1],'LineWidth',2);
    plot(Spikes(1,:),Spikes(3,:),':','LineWidth',2,'Color',[0.6 0 0.1]);
    plot(Spikes(1,:),Spikes(4,:),'LineWidth',2,'Color',[0.6 0 0.1]);
    hold off
    axis tight
    grid on
    xlabel('Frequency (Hz)')
    ylabel('Mean amplitude spectrum')
    xlim([Fmin Fmax])
    title(str_title)
    legend('Detected spikes','FFT amplitude spectrum','Median spectrum','Hampel Threshold')
else
    plot(Spikes(1,:),Spikes(2,:),'LineWidth',2,'Color',[0.2 0.4 1]);
    axis tight
    grid on
    xlabel('Frequency (Hz)')
    ylabel('Mean amplitude spectrum')
    xlim([Fmin Fmax])
    title(str_title)
end




