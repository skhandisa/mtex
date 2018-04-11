function sFs = symmetrise(sF, varargin)
% symmetrises a function with respect to a symmetry 
%
% Syntax
%
%   % symmetrise with respect to a crystal or specimen symmetry
%   sFs = symmetrise(sF,cs)
%   sFs = symmetrise(sF,ss)
%
%   % symmetrise with respect to an axis
%   sFs = symmetrise(sF,d)
%
% Input
%  sF    - @S2FunHarmonic
%  cs,ss - @crystalSymmetry, @specimenSymmetry
%  d     - @vector3d
%
% Output
%  sFs - symmetrised @S2FunHarmonic
%

% symmetrise with respect to an axis
if isa(varargin{1},'vector3d')
  
  % rotate sF such that varargin{1} -> z
  if varargin{1} ~= zvector
    rot = rotation('axis',cross(varargin{1},zvector),'angle',-angle(varargin{1},zvector));
    sF = rotate(sF,rot);
  end
  
  % set all Fourier coefficients f_hat(l,k)=0 for k ~= 0
  sFs = S2FunHarmonic(0);
  M = sF.bandwidth;
  sFs.bandwidth = M;
  sFs.fhat((0:M).^2+(1:M+1)) = sF.fhat((0:M).^2+(1:M+1));
  
  % rotate sF back
  if varargin{1} ~= zvector
    sFs = rotate(sFs,inv(rot));
  end
  
  return;
end


% extract symmetry
sym = getClass(varargin,'symmetry');

% maybe we can set antipodal and save some time
if sym.isLaue
  symX = sym.properSubGroup;
  varargin = [varargin,'antipodal'];
else
  symX = sym;
end

% maybe there is nothing to do
if sF.bandwidth == 0 || length(symX) == 1
  sFs = S2FunHarmonicSym(sF.fhat, sym, varargin{:});
  return;
end

% define a symmetrized evaluation function
f = @(v) sF.eval(v);
fsym = @(v) mean(reshape(f(symX * v),length(symX),[]));

% compute Fourier coefficients by quadrature
sF = S2FunHarmonic.quadrature(fsym, 'bandwidth', sF.bandwidth,varargin{:});

% set up S2FunHarmonicSym
sFs = S2FunHarmonicSym(sF.fhat,sym);

end
