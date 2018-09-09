
% plot dprime and ratios for all groups

figure; 
set(gcf,'DefaultAxesColorOrder',[0 0 0;0 0 1;1 0 0; 0,1,0]);
semilogx(cvalues(1,:),squeeze(dprime(2,:))','g.-', 'MarkerSize', 18);
hold on
semilogx(cvalues(1,:), mean(detdet(:,2:8,1)), 'k.-', 'MarkerSize', 18);
hold on
% semilogx(cvalues(1,:), mean(det4day(:,2:8,1)), 'ks-', 'MarkerSize', 10);
% hold on
semilogx(cvalues(1,:), mean(detectid(:,2:8,1)), 'k*-', 'MarkerSize', 10);
hold on
semilogx(cvalues(1,:), mean(detdet(:,2:8,2)), 'r.-', 'MarkerSize', 18);
hold on
% semilogx(cvalues(1,:), mean(det4day(:,2:8,2)), 'rs-', 'MarkerSize', 10);
% hold on
semilogx(cvalues(1,:), mean(iddetect(:,2:8,1)), 'r+-', 'MarkerSize', 10);
hold on
%legend('ideal', 'det-det day 1', 'det-4 day 1', 'det-id day 1', 'det-det day 2', 'det-4 day 2', 'id-det day 2');
legend('ideal', 'det-det day 1', 'det-id day 1', 'det-det day 2', 'id-det day 2');
xlabel('Contrast (rms)')
ylabel('dprime')


% plot ratio of human to ideal dprime (squared)

figure;
semilogx(cvalues(1,:), (dprime(2,:)./mean(detdet(:,2:8,1))).^2, 'k.-', 'MarkerSize', 18);
hold on
% plot(cvalues(1,:), (dprime(2,:)./mean(det4day(:,2:8,1))).^2, 'ks-', 'MarkerSize', 10);
% hold on
semilogx(cvalues(1,:), (dprime(2,:)./mean(detectid(:,2:8,1))).^2, 'k*-', 'MarkerSize', 10);
hold on
semilogx(cvalues(1,:), (dprime(2,:)./mean(detdet(:,2:8,2))).^2, 'r.-', 'MarkerSize', 18);
hold on
semilogx(cvalues(1,:), (dprime(2,:)./mean(iddetect(:,2:8,1))).^2, 'r+-', 'MarkerSize', 10);
hold on
% plot(cvalues(1,:), (dprime(2,:)./mean(det4day(:,2:8,2))).^2, 'rs-', 'MarkerSize', 10);
% hold on
ylim([0,30])
legend('det-det day 1', 'det-id day 1', ' det-det day 2', 'id-det day 2'); 
xlabel('Contrast (rms)');
ylabel('(Ideal dprime / obs dprime)^2');


% ratio for 4-day experiment
figure; 
hold on
plot(cvalues(1,:), (dprime(2,:)./mean(det4day(:,2:8,1))).^2, 'k*-', 'MarkerSize', 10);
hold on
plot(cvalues(1,:), (dprime(2,:)./mean(det4day(:,2:8,2))).^2, 'r*-', 'MarkerSize', 10);
hold on
plot(cvalues(1,:), (dprime(2,:)./mean(det4day(:,2:8,3))).^2, 'b*-', 'MarkerSize', 10);
hold on
plot(cvalues(1,:), (dprime(2,:)./mean(det4day(:,2:8,4))).^2, 'm*-', 'MarkerSize', 10);
legend('day 1', 'day 2', ' day 3', 'day 4'); 
xlabel('Contrast (rms)');
ylabel('(Ideal dprime / obs dprime)^2');
