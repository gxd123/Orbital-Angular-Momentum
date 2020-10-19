% Main Method : the back projection(BP) algorithm
%
% Reference :
%   Gui-ron, Guo. ��Electromagnetic vortex based radar target imaging.�� 
%   Journal of National University of Defense Technology (2013).

clc;
clear;
close all;

% ====== ������ =======

c = 299792458 ;

% ====== �ز����� =======

frequency = 6e9;
lambda = c / frequency;
k = 2.0 * pi / lambda; 

% ====== ���в��� =======

a = 20 * lambda;

% ====== �������� ======= 

rm = 500 * lambda;
thetam = pi/3;
phim = pi/4;

% ====== ģʽȡֵ��Χ ======= 

maxL = 30;
minL = -30;

% ====== �ز��ź� ======= 

s = @(mode) exp(1i*2*k*rm)/rm^2 ...
    .* exp (1i*2*mode*phim) ...
    .* besselj(mode, k * a * sin(thetam)).^2;

% ====== ��ͶӰ�� ======= 

r = @(mode,theta,phi) s(mode)...
    .*  exp (-1i*2*mode*phi) ...
    .* conj((besselj(mode, k * a * sin(theta))).^2);

% ������λ�Ƿ�Χ
phi = -pi:0.01*pi:pi;
theta0 = pi/3;

res = zeros(length(phi));
for i = 1:length(phi)
    res(i) = abs(integral(@(mode) r(mode,theta0,phi(i)),minL,maxL));
end

plot(phi/pi,res,'k');
xlabel('��λ��');
ylabel('��ֵ');