
clc
clear all
close all

% load the data
startdate = '01/01/1994';
enddate = '12/31/2022';
f = fred
JP = fetch(f,'JPNRGDPEXP',startdate,enddate)
AU = fetch(f,'NGDPRSAXDCAUQ',startdate,enddate)
jp = log(JP.Data(:,2));
au = log(AU.Data(:,2));
q = JP.Data(:,1);

T = size(jp,1);

% Hodrick-Prescott filter
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

tauJGDP = A\jp;
tauAGDP = A\au;

% detrended GDP
jptilde = jp-tauJGDP;
autilde = au-tauAGDP;

% plot detrended GDP
dates = 1994:1/4:2023.1/4;
figure
title('Detrended log(real GDP) 1994Q1-2022Q4'); hold on
plot(q, jptilde,'r', q, autilde,'b')
datetick('x', 'yyyy-qq')
legend('JPN', 'AUS', 'Location', 'best')

% compute sd(y), sd(c), rho(y), rho(c), corr(y,c) (from detrended series)
ysd = std(jptilde)*100;
csd = std(autilde)*100;
corryc = corrcoef(jptilde(1:T),autilde(1:T)); corryc = corryc(1,2);

disp(['Percent standard deviation of detrended log real JPN GDP: ', num2str(ysd),'.']); disp(' ')
disp(['Percent standard deviation of detrended log real AUS GDP: ', num2str(csd),'.']); disp(' ')
disp(['Contemporaneous correlation between detrended log real JPN and AUS: ', num2str(corryc),'.']);
