function [sig] = generateOAM(opt)

%
% UCA����������OAM�����漰�ź�Դ��б�ǣ�
%
% ========== INPUT PARAMETER ===========
%
% X, Y  : �۲�ƽ��� x �� y �����귶Χ
% f     : �ز�Ƶ��
% l     : OAM ģʽ��
% N     : ������Ԫ��
% a     : ���߰뾶 m
% amps  : ���߸���Ԫ�ļ���Դ����
% z0    : �۲�ƽ������ߵľ���
% tilt  : �ź�Դ����б��
% ============ OUTPUTS ===================

% �ж��Ƿ����
if (isfield(opt, 'active') && ~opt.active)
  return;
end

if ~isfield(opt,'frequency') ||...
    isempty(opt.frequency) 

    error('�������ź�Ƶ��');
end

if ~isfield(opt,'l') ||...
    isempty(opt.l) 
    error('������OAMģʽ��');
end

if ~isfield(opt,'nElem') ||...
    isempty(opt.nElem) 
    error('��������������');
end


% ====== �������� =======

c = 299792458 ;                        % ���� m/s
lambda = c / opt.frequency ;           % ���� m
k = 2.0 * pi / lambda;                 % ���� 

if ~isfield(opt,'type') ||...
    isempty(opt.type) ||...
    strcmp(opt.type , 'observe')
    opt.type = 'observe';
    opt = checkField(opt, 'obsRange', {'numeric'},{'real','nonnan'},25*lambda);
    opt = checkField(opt, 'obsCount', {'numeric'},{'real','nonnan'},2^10);
    opt = checkField(opt, 'Z0', {'numeric'},{'real','nonnan'},25*lambda);
    opt = checkField(opt, 'tilt', {'numeric'},{'real','nonnan'},0);
    
elseif strcmp(opt.type , 'point')
    isDefPoint = isfield(opt,'mRadius') ...
        && ~isempty(opt.mRadius) ...
        && isfield(opt,'mPsi') ...
        && ~isempty(opt.mPsi) ...
        && isfield(opt,'mTheta') ...
        && ~isempty(opt.mTheta);

    isNumEqual = isequal(size(opt.mRadius) , size(opt.mPsi)) ...
        && isequal(size(opt.mPsi),size(opt.mTheta) ); 
    
    if ( ~isNumEqual || ~isDefPoint ) 
        error('��������ȷ����������');
    end
    
else
    error('��������ȷ������');
end

opt = checkField(opt, 'elemExcitation', {'numeric'},{'real','positive','nonnan','finite'},1);
opt = checkField(opt, 'arrayRadius', {'numeric'},{'real','nonnan'},2*lambda);


% ====== UCA���� =======

elemPhi = 2.0 * pi  / opt.nElem * ( 0 :  opt.nElem - 1 );  % ���߸���Ԫ�ķ����

% ====== �����źŻ������� =======

sig.physical.frequency = opt.frequency;
sig.physical.l = opt.l;

if strcmp(opt.type , 'observe')
    % �õ���ά�ѿ�������ϵ
    sig.type = 'observe';
    X = linspace (-opt.obsRange, opt.obsRange, opt.obsCount);
    Y = linspace (-opt.obsRange, opt.obsRange, opt.obsCount);
    [x,y] = meshgrid(X,Y);
    
    % ====== ���UCA���䳡 =======

    E = zeros(length(y),length(x));        % ��ʼ�����䳡

    for n = 1 : opt.nElem
        E = E + spherical(...
            k,...
            x - opt.arrayRadius * cos(elemPhi(n))*cos(opt.tilt),...
            y - opt.arrayRadius * sin(elemPhi(n)),...
            opt.Z0 + opt.arrayRadius * cos(elemPhi(n))*sin(opt.tilt)...
            )...
            *opt.elemExcitation * exp( 1i * elemPhi(n) * opt.l);
    end
    
    sig.samples{1} = E;

elseif strcmp(opt.type , 'point')
    
    sig.type = 'point';
    sig.scatteringPoint.radius = opt.mRadius;
    sig.scatteringPoint.phi = opt.mPsi;
    sig.scatteringPoint.theta = opt.mTheta;
    
    E = opt.elemExcitation * exp(-1i * k * opt.mRadius) ./ opt.mRadius ...
        * opt.nElem * 1i^opt.l ...
        .* exp(1i * opt.l * opt.mPsi)...
        .*besselj(opt.l, k * opt.arrayRadius * sin(opt.mTheta));
    
    sig.samples{1} = E;
end

end

function output = spherical(k, x, y, z)
    %
    % ���������ڼ���Բ����λ��
    %
    % ======= INPUT PARAMETER =======
    % k         :  ����
    % x , y , z :  �۲�ƽ��ĵѿ�������ϵ
    %
    r = sqrt(x.^2 + y.^2 + z.^2);
    output = exp(-1i*k*r)./r;
end