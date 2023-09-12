function lum = rgb2lum( rgb )% RGB2LUM  Convert RGB values to luminances (cd/m^2)%% lum = rgb2lum( rgb )% 16-Apr-98 -- created (RFM)% 14-Apr-98 -- support created for multiple monitors (RFM)% 24-Aug-99 -- adapted for bit-stealing clut (RFM)lum=0.3*grey2lum(rgb(:,1))+0.6*grey2lum(rgb(:,2))+0.1*grey2lum(rgb(:,3));return