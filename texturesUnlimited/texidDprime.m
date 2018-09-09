
tmpdat=importdata('versatileData.csv');
data=tmpdat.data;
dplookup=csvread('dprime10afc.csv');

dprimeMatrix=zeros(84,24);

for rows=1:84
    for cols=1:24
        pc=data(rows, cols);
        pc=round(pc*100)/100;    
        dpindex=find(dplookup(:,1)==pc);
        dp=dplookup(dpindex,2);
    
        dprimeMatrix(rows,cols)=dp;
    end
end

        
   
