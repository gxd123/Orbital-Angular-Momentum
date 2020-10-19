function sig = calcOAM( opt )

    addpath('..\Common');
    % �ж��Ƿ����
    if (isfield(opt, 'active') && ~opt.active)
      return;
    end  
    
    if ~isfield(opt.sphCoord,'radius') ||...
        isempty(opt.sphCoord.radius) ||... 
        ~isfield(opt.sphCoord,'azimuth') ||...
        isempty(opt.sphCoord.azimuth) ||... 
        ~isfield(opt.sphCoord,'elevation') ||...
        isempty(opt.sphCoord.elevation)
        error('�������źŷ�Χ');
    end
    
    sphCoord = opt.sphCoord ;
    
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
    
    % ====== �ز����� =======
    
    c = 299792458 ;                        % ���� m/s
    lambda = c / opt.frequency ;           % ���� m
    k = 2.0 * pi / lambda;                 % ���� 
    
    opt = checkField(opt, 'arrayRadius', {'numeric'},{'real','nonnan'},2*lambda);

    % ====== ������䳡 =======
    
    E = exp(-1i * k * sphCoord.radius)./sphCoord.radius...
        * opt.nElem * 1i^(opt.l)...
        .* exp(1i * opt.l * sphCoord.azimuth)...
        .* besselj(opt.l, k * opt.arrayRadius * sin(sphCoord.elevation));
    
    sig.samples{1} = E;
end

