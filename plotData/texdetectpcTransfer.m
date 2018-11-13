
clear all
ID=503;

nz=[0.01, 0.1];
c=8;
pca = zeros(length(nz), c, 2); % noise by contrast by day
zfaa=zeros(2,1,2);
dpa = zeros(2,7,2); % noise by contrast by day

h = figure();
set(h, 'Position', [500 900 1000 300]);

% Make sure to select the right one for the subject
cond={'LowA','High'};
% cond={'LowA','LowA'};
% cond={'High','LowA'};
% cond={'High','High'};

for c=1:2
    for run=1:2
        matfilename = ['grp20_ID', num2str(ID), '_Textures_', cond{c},'_N', num2str(run)];
        %[~,id] = fileparts(matfilename(9:12));
        load(matfilename);
        
        for j = 1:length(nz)
            for k = 1:length(unique(values(j,:)))
                contrast = unique(values(j,:));
                tmp = data(data(:,3)==nz(j) & data(:,4)==contrast(k),:);
                pca(j,k, run) = mean(tmp(:,7));
            end
            
            if pca(j,1,run)==0, pca(j,1,run)=0.0001; end
            if pca(j,1,run)==1, pca(j,1,run)=0.9999; end
            zfaa(j,1,run) = norminv(1-pca(j,1,run));
            contrast = 2;
            for kk = 1:7
                pc2 = pca(j, contrast, run);
                if pc2==1, pc2=.9999; end
                dpa(j,kk, run)=norminv(pc2)-zfaa(j,1,run);
                contrast=contrast+1;
            end % contrast loop
        end % noise loop
    end % run loop
    ymax=1.2*max(dpa(:));
    subplot(1,3,c);
    
   
    semilogx(15, linspace(0.3, 3, 15), 'w.')
    hold on
    plot(values(1,8:14), dpa(1,:,1), 'r.-');
    plot(values(1,8:14), dpa(1,:,2), 'r.--');
    plot(values(2,8:14), dpa(2,:,1), 'b.-');
    plot(values(2,8:14), dpa(2,:,2), 'b.--');
    line([0.4*values(1,8) 1.6*values(2,14)],[0,0], 'Color','black','LineStyle','-')
    axis([0.4*values(1,8) 1.6*values(2,14) -1, ymax])
    %axis([10e-7 10e-4 -1, 4.5])
    if c==1
       %legend({'','Day 1: 0.01', 'Day 2','Day 1: 0.1', 'Day 2', ''});
        %legend('boxoff')
        text(values(2,10), 0.95*ymax, num2str(ID))
    end
    xlabel('Contrast')
    ylabel('dprime')
    title(cond{c})

    

end % condition loop

