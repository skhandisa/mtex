function pl = smooth(p,iter)
% smooth grain-set by edge contraction

if nargin <2 || isempty(iter)
  iter = 1;
end


pl = polyeder(p);

hpl = {pl.Holes};
hs = cellfun('prodofsize',hpl);
pl = [pl [hpl{:}]];

n = numel(p);
Vertices = get(pl,'Vertices');
VertexIds = get(pl,'VertexIds');

Faces = get(pl,'Faces');
FacetIds = get(pl,'FacetIds');

nv = max(cellfun(@max,VertexIds)); % number of vertices
nf = max(cellfun(@max,FacetIds)); % number of faces
df = max(cellfun('size',Faces,2)); % dim of faces

V = zeros(nv,3);
F = zeros(nf,df);
for k=1:n
  v = VertexIds{k};
  V(v,:) =  Vertices{k};
  F(FacetIds{k},:) = v(Faces{k});
end

F = F(any(F ~= 0,2),:); % erase nans
F(:,end+1) = F(:,1);

for k=1:df
  E{k} =  F(:,k:k+1);
end
E = vertcat(E{:});

uE = unique(E(:));
d = histc(E(:),uE);
fd = sparse(uE,1,d);

for l=1:iter
  Ve = reshape(V(E,:),[],2,3);
  
  dV = diff(Ve,1,2);
  dist = exp(-sqrt(sum(dV.^2,3)));
  w = cat(3,dist,dist,dist).*dV;
  
  Ve = Ve + cat(2,w,-w); % shifting vertices
  
  for k=1:3
    V(:,k) = full(sparse(E(:),1,Ve(:,:,k))./fd);
  end
end

for k=1:n
  pl(k).Vertices = V(VertexIds{k},:);
end

hpl = pl(n+1:end);
cs = [0 cumsum(hs)];
for k=1:numel(p)
  spl = hpl(cs(k)+1:cs(k+1));
  
  if ~isempty(spl)
    pl(k).Holes = spl;
  end
end

