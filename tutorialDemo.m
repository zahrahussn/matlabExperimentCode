
 a=[50, 50, 50, 50, 50, 50, 50, 50, 51, 51, 51, 51, 51, 49, 49, 49, 49, 49, 52, 48];
 samplesa=zeros(6,5);
 
 b=[5,10,15,20,25,30,35,40,45,50,50, 55,60,65,70,75,80,85,90,95];
 samplesb=zeros(6,5);
 
 for samples=1:6
     permutation=randperm(20);
     index=permutation(1:5);
     draw=a(index);
     samplesa(samples,:)=draw;
 end
 
         
     
 for samples=1:6
     permutation=randperm(20);
     index=permutation(1:5);
     draw=b(index);
     samplesb(samples,:)=draw;
 end
 
 means=zeros(6,2);
 sems=zeros(6,2);
 
 for sample=1:6
     means(sample,1)=mean(samplesa(sample,:));
     means(sample,2)=mean(samplesb(sample,:));
 end;
 
 sema=std(means(:,1));
 semb=std(means(:,2));