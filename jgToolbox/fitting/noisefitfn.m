function [ params ] = noisefitfn( data, init )% function [ params ] = noisefitfn( data, init )%% fits a linear noise masking function to data. data are independant % and dependant data, stored in a 2 column matrix. init are the initial% values for the parameters.defarg('init',[mean(data(:,1)),1]);sz = size(data);if sz(2) == 2	data = [data,ones(sz(1),1)];enddata(:,3) = (data(:,3)).^(-1);errfn = inline('sum( ((x(1)*(P1(:,1)  + x(2)) - P1(:,2)).^2)./P1(:,3))',1);options=foptions;%options(1)=1;options(2)=1e-10;options(3)=1e-10;options(14)=10000;params = fmins(errfn,init,options,[],data);return