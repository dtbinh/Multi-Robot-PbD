function [w,new]=dtwMD(t,r)
% DTWMD Summary of this function goes here
%   Detailed explanation goes here

%Dynamic Time Warping Algorithm
%Dist is unnormalized distance between t and r
%D is the accumulated distance matrix
%k is the normalizing factor
%w is the optimal path
%t is the vector you are testing against
%r is the vector you are testing

%Data size checking, get distance matrix in referenced r's dim
[row_r, col_r] = size(r);
[row_t, col_t] = size(t);

if col_r ~= col_t
    disp 'Error: Data dim mismatch.';
    return;
else
    col = col_r;
    fprintf('\tDimension check : Success. (=%d)\n', col);
end

%Compute distance
d = zeros(row_r, row_t);
for n=1:row_r
    for m=1:row_t
        for i=1:col
            d(n,m)= d(n,m) + (r(n,i) - t(m,i))^2;
        end
    end
end

%d=(repmat(t(:),1,M)-repmat(r(:)',N,1)).^2; %this replaces the nested for loops from above Thanks Georg Schmitz 

D=zeros(size(d));
D(1,1)=d(1,1);

for n=2:row_r
    D(n,1)=d(n,1)+D(n-1,1);
end
for m=2:row_t
    D(1,m)=d(1,m)+D(1,m-1);
end
for n=2:row_r
    for m=2:row_t
        D(n,m)=d(n,m)+min([D(n-1,m),D(n-1,m-1),D(n,m-1)]);
    end
end

Dist=D(row_r, row_t);
n=row_r;
m=row_t;
k=1;
w=[];
w(1,:)=[row_r,row_t];
while ((n+m)~=2)
    if (n-1)==0
        m=m-1;
    elseif (m-1)==0
        n=n-1;
    else 
      [values,number]=min([D(n-1,m),D(n,m-1),D(n-1,m-1)]);
      switch number
      case 1
        n=n-1;
      case 2
        m=m-1;
      case 3
        n=n-1;
        m=m-1;
      end
    end
    k=k+1;
    w=cat(1, w,[n,m]);
end

% Align t serials to r (reference) serials  
b = t;
w = w(end:-1:1, :);
new_b = zeros(row_r,col);
index = 1;
for i = 1:row_r
    counter = 1;
    sum = b(w(index,2), :);
    for j = index+1:k
        if w(index,1) == w(j,1)
           counter = counter + 1;
           sum = sum + b(w(j,2), :);
        else
            break;
        end
    end
    index = index + counter;
    new_b(i, :) = sum / counter;
end
new = new_b;
end

