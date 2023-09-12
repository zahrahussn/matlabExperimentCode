function [ params ] = expfitfn( data, init )% function [ params ] = expfitfn( data, init )%% fits and exponential to data. data are independant and dependant% data, stored in a 2 column matrix. init are the intial values for% the parameters.%% May 1998  JMG U of T Vision Labdefarg('init',[mean(data(:,1)),1]);sz = size(data);if sz(2) == 2	data = [data,ones(sz(1),1)];enddata(:,3) = (data(:,3)).^(-1);%errfn = inline('sum(((x(1) + x(2)*exp(-x(3)*P1(:,1)) + x(4)*exp(-x(5)*P1(:,1))) - P1(:,2)).^2)./P1(:,3))',1);errfn = inline('sum(((x(1)*exp(x(2)*P1(:,1)) - P1(:,2)).^2)./P1(:,3))',1);options=foptions;%options(1)=1;options(2)=0;options(3)=0;options(14)=1000;params = fmins(errfn,init,options,[],data);return