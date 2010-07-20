function odf = fibreODF(h,r,CS,SS,varargin)
% defines an fibre symmetric ODF
%
%% Description
% *fibreODF* defines a fibre symmetric ODF with respect to 
% a crystal direction |h| and a specimen directions |r|. The
% shape of the ODF is defined by a @kernel function.
%
%% Syntax
%  odf = fibreODF(h,r,CS,SS,'halfwidth',hw)
%  odf = fibreODF(h,r,CS,SS,kernel)
%
%% Input
%  h      - @Miller / @vector3d crystal direction
%  r      - @vector3d specimen direction
%  CS, SS - crystal, specimen @symmetry
%  hw     - halfwidth of the kernel (default - 10°)
%  kernel - @kernel function (default - de la Vallee Poussin)
%
%% Output
%  odf -@ODF
%
%% See also
% ODF/ODF uniformODF unimodalODF

error(nargchk(4, 6, nargin));
argin_check(h,'Miller');
argin_check(r,'vector3d');
argin_check(CS,'symmetry');
argin_check(SS,'symmetry');
h = set(h,'CS',CS);

if check_option(varargin,'bingham') % Bingham distributed ODF
  
  kappa = get_option(varargin,'bingham',10);
  
  if length(kappa) == 1, kappa = [kappa,0];end
  
  q1 = normalize(idquaternion - quaternion(0,r) * quaternion(0,h));
  q2 = normalize(quaternion(0,r) + quaternion(0,h));
  
  if isnull(norm(h-r))
    v1 = orth(h);
    v2 = cross(h,v1);
    q3 = quaternion(0,v1);
    q4 = quaternion(0,v2);
  else
    q3 = normalize(idquaternion + quaternion(0,r) * quaternion(0,h));
    q4 = normalize(quaternion(0,r) - quaternion(0,h));
  end
  
  odf = BinghamODF([kappa(1) kappa(1) kappa(2) kappa(2)],[q1,q2,q3,q4],CS,SS);
  
  % reverse:
  %h_0 = q_1^* q_2
  %r_0 = q_2 q_1^*.
    
else % pure FibreODF

  if ~isempty(varargin) && isa(varargin{1},'kernel')
    psi = varargin{1};
  else
    hw = get_option(varargin,'halfwidth',10*degree);
    psi = kernel('de la Vallee Poussin','halfwidth',hw);
  end

  odf = ODF({h,r},1,psi,CS,SS,'fibre');
end
