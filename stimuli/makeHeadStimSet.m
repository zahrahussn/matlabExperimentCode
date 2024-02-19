
A3 = [-30,0,30];
A4 = [0,200];
A5 = [0,0];

phiRots = [0 -18 -24];

nA3 = length(A3);
nA4 = length(A4);
nA5 = length(A5);
for phiRot = phiRots
    figure('name',sprintf('phiRot = %+d', phiRot),'units','normalized','position',[0 .5*(abs(phiRot)==0) 1 .45]);
    tiledlayout(nA5,nA3*nA4,'TileSpacing','compact')
    for i = 1:nA3
        for j = 1:nA4
            for k = 1:nA5
                hAxes = nexttile( (k-1)*nA3*nA4 + (i-1)*nA4 + j );
                makeRadialStim([1 2 3 4 5 6 7],[7 20 5*(100+A3(i))/100 1*(100+A4(j))/100  0.4*(100+A5(k))/100  0.5 0.3],...
                    [0 0 180+phiRot 0+phiRot 180-0.15*phiRot 180 180],0,hAxes);
                if k == 1
                    title(sprintf('A3 = %+d%%',A3(i)));
                end
                if j == 1
                    ylabel(sprintf('A5 = %+d%%',A5(k)));
                end
                if k == nA5
                    xlabel(sprintf('A4 = %+d%%',A4(j)));
                end
    %             set(gcf,'name', )
            end
        end
    end
end
