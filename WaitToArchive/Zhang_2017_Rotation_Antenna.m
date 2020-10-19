% Main Method : Rotational Antenna
%
% Reference :
%   Zhang, C. and D. Chen. ��Large-Scale Orbital Angular Momentum Radar Pulse Generation With Rotational Antenna.�� 
%       IEEE Antennas and Wireless Propagation Letters 16 (2017): 2316-2319.
%

clc;
clear;
close all;

% ====== ������ =======

c = 299792458 ;

% ====== �ز����� =======

f = 9e9;
lambda = c / f;
k = 2.0 * pi / lambda;  

% ====== ��ת���� =======

N = 64;
a = 5*lambda;
l = 2;

m = 10e6;
omega = 30e9;
Omega = omega / (m*N+l);

z0 = 50 * lambda;
dT = 2.0 * pi /(N*Omega);
nPhi = (0:N) * dT;

% ====== �۲�ƽ�� =======

ra =15*lambda;
x_count = 1001 ;
y_count = 1001 ;

X = linspace (-ra, ra, x_count);
Y = linspace (-ra, ra, y_count);
[x,y] = meshgrid(X,Y);

z = ones(length(Y),length(X)) * z0;
[azimuth, elevation, radius] = cart2sph(x,y,z);
elevation = pi/2 - elevation;

% ====== �����䳡 =======

E = zeros(length(y),length(x)); 

for n = 1:N
    E = E + exp(-1i*k*radius)./radius ...
        .*exp(1i*k*a*sin(elevation).*cos(azimuth-nPhi(n)*Omega))...
        *exp(-1i * omega * nPhi(n));
end

% ====== ��ͼ =======

figure(1)
surf(x,y,E.*conj(E));
xlim([min(X),max(X)]);
ylim([min(Y),max(Y)]);
title('ǿ�ȷֲ�');
shading interp;
view(2);
colorbar;

figure(2)
surf(x,y,angle(E)/pi*180);
xlim([min(X),max(X)]);
ylim([min(Y),max(Y)]);
title('��λ�ֲ�');
shading interp;
view(2);
h = colorbar('southoutside');
set(h, 'xlim' , [-180,180]);
set(h, 'xtick' , -180 : 180 : 180 );
set(h, 'xticklabel' , {'-180��','0��','180��'});