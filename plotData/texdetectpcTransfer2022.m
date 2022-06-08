%close all
% llids=[605, 607, 609, 611, 613, 621, 622, 629];
% hhids=[600, 603, 606, 614, 626, 628, 630];
% lhids=[615, 616, 623,624, 627,631,632];
% hlids=[601, 610, 618,625];

% g1 = low, low
% g2 = high, high
% g3 = low, high
% g4 = high, low

ID=703;
g=2;
nruns=1;

nz=[0.01, 0.1];
c=8;
pca = zeros(length(nz), c, 2); % noise by contrast by day
zfaa=zeros(2,1,2);
dpa = zeros(2,7,2); % noise by contrast by day
plotvalues=zeros(2,7,2);
lw=1;

if g==1
    cond={'LowA','LowA'};
    n2=2;
    axmult=0.6;
    axmult2=1.6;
    caption = [num2str(ID), ' low - low'];
else
    if g==2
        cond={'High','High'};
        n2=2;
         axmult=0.8;
         axmult2=1.2;
         caption = [num2str(ID),' high - high'];
    else
        if g==3
            cond={'LowA','High'};
            n2=1;
            axmult=0.6;
            axmult2=4;
            caption = [num2str(ID),' low - high'];
        else
            cond={'High','LowA'};
            n2=1;
            axmult=0.2;
            axmult2=1.6;
            caption = [num2str(ID),' high - low'];
        end
    end
end

    for run=1:nruns
        if run==1
            n=1;
        else
            n=n2;
        end
        matfilename = ['grp20_ID', num2str(ID), '_Textures_', cond{run},'_N', num2str(n)];
        %[~,id] = fileparts(matfilename(9:12));
        load(matfilename);
        size(data);
        plotvalues(:,:,run)=values(:,8:14);
        
        for j = 1:length(nz)
            for k = 1:length(unique(values(j,:)))
                contrast = unique(values(j,:));
                tmp = data(data(:,3)==nz(j) & data(:,4)==contrast(k),:);
                pca(j,k, run) = mean(tmp(:,7));
            end
            
            if pca(j,1,run)==0, pca(j,1,run)=0.01; end
            if pca(j,1,run)==1, pca(j,1,run)=0.99; end
            zfaa(j,1,run) = norminv(1-pca(j,1,run));
            contrast = 2;
            for kk = 1:7
                pc2 = pca(j, contrast, run);
                if pc2==1, pc2=.99; end
                dpa(j,kk, run)=norminv(pc2)-zfaa(j,1,run);
                contrast=contrast+1;
            end % contrast loop
        end % noise loop
    end % run loop
    pca(:,1,:)
    
    figure;
    subplot(2,1,1)
    semilogx(15, linspace(0.2, 1, 15), 'w.')
    hold on
    h(1) = plot(plotvalues(1,:,1), pca(1,2:8,1), 'r.-', 'MarkerSize',12,'LineWidth',lw);
    h(2) = plot(plotvalues(2,:,1), pca(2,2:8,1), 'b.-', 'MarkerSize',12,'LineWidth',lw);
    h(3) = plot(plotvalues(1,:,2), pca(1,2:8,2), 'r.--','MarkerSize',12,'LineWidth',lw);
    h(4) = plot(plotvalues(2,:,2), pca(2,2:8,2), 'b.--', 'MarkerSize',12,'LineWidth',lw);
    axis([axmult*plotvalues(1,1) axmult2*plotvalues(2,7) 0.2, 1.1])
    ylabel('hit')
    legend(h,{'Day 1 low noise','Day 1 high noise', 'Day 2','Day 2'}, 'Location','northwest');
    legend('boxoff')
    title(caption) 
    
    
    subplot(2,1,2)
    ymax=1.2*max(dpa(:));
    set(gcf, 'Position',  [1100, 600, 800, 800])
    
    semilogx(15, linspace(0.3, 3, 15), 'w.')
    hold on
    h(1)=plot(plotvalues(1,:,1), dpa(1,:,1), 'r.-', 'MarkerSize',12,'LineWidth',lw);
    h(2)=plot(plotvalues(2,:,1), dpa(2,:,1), 'b.-', 'MarkerSize',12,'LineWidth',lw);
    h(3)=plot(plotvalues(1,:,2), dpa(1,:,2), 'r.--', 'MarkerSize',12,'LineWidth',lw);
    h(4)=plot(plotvalues(2,:,2), dpa(2,:,2), 'b.--', 'MarkerSize',12,'LineWidth',lw);
    line([axmult*plotvalues(1,1) axmult2*plotvalues(2,7)],[0,0], 'Color',[.5 .5 .5],'LineStyle','-.')
    axis([axmult*plotvalues(1,1) axmult2*plotvalues(2,7) -1, ymax])
    xlabel('Contrast')
    ylabel('dprime')
    


