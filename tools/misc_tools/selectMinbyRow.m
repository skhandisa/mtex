function [A,varargout] = selectMinbyRow(A,varargin)
% find maximum in each row

% find maximum values
ind = A == repmat(min(A,[],1),size(A,1),1);

% select only the first maximum
ind = ind & ind == cumsum(ind,1);

% return results
A = A(ind);

for i = 1:nargout-1
  varargout{i} = varargin{i}(ind);
end
