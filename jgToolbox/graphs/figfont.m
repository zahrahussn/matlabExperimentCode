function figfont( fontname )% FIGFONT  Set font of the axes, axis labels and title of a figure% 01/05/98 - created (RFM)set(gca,'FontName',fontname);set(get(gca,'XLabel'),'FontName',fontname);set(get(gca,'YLabel'),'FontName',fontname);set(get(gca,'ZLabel'),'FontName',fontname);set(get(gca,'Title'),'FontName',fontname);return