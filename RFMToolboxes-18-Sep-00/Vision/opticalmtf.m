function mod = opticalmtf( f )% OPTICALMTF - optical modulation transfer function%% mod = opticalmtf( f )%     - <f> is spatial frequency (cpd)%     - <mod is modulation% constants from Campell and Gubisch (1968), via Geisler's WAVSDE softwarew=0.538;msa2=1/(4*pi^2*5.45e-5);msb2=1/(4*pi^2*1.16e-3);mod = w*exp( -(f.^2)./(2*msa2) ) + (1-w)*exp( -(f.^2)./(2*msb2) );return