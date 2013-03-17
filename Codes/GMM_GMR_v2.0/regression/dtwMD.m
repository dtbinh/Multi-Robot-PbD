function [Dist,D,k,w,new]=dtwMD(t,r)
%DTWMD Summary of this function goes here
%   Detailed explanation goes here

%Dynamic Time Warping Algorithm
%Dist is unnormalized distance between t and r
%D is the accumulated distance matrix
%k is the normalizing factor
%w is the optimal path
%t is the vector you are testing against
%r is the vector you are testing

%Data size checking
%t = t';
%r = r';
[row, col]=size(t);
if [row, col] ~= size(r)
    disp 'Error: Data size mismatch.';
    return;
end

%Compute distance
for n=1:col
    for m=1:col
        for i=1:row
            d(n,m)=(t(i,n)-r(i,m))^2;
        end
    end
end
%d=(repmat(t(:),1,M)-repmat(r(:)',N,1)).^2; %this replaces the nested for loops from above Thanks Georg Schmitz 

D=zeros(size(d));
D(1,1)=d(1,1);

for n=2:col
    D(n,1)=d(n,1)+D(n-1,1);
end
for m=2:col
    D(1,m)=d(1,m)+D(1,m-1);
end
for n=2:col
    for m=2:col
        D(n,m)=d(n,m)+min([D(n-1,m),D(n-1,m-1),D(n,m-1)]);
    end
end

Dist=D(col,col);
n=col;
m=col;
k=1;
w=[];
w(1,:)=[col,col];
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
    w=cat(1,w,[n,m]);
end
%% Align t serials to r (reference) serials (original r and t have the same length.) 
b = r;
w = w(end:-1:1, :)
new_b = zeros(row,col);
index = 1;
for i = 1:col
    counter = 1;
    sum = b(:,w(index,2));
    for j = index+1:k
        if w(index,1) == w(j,1)
           counter = counter + 1;
           sum = sum + b(:,w(j,2));
        else
            break;
        end
    end
    index = index + counter;
    new_b(:,i) = sum / counter;
end
new = new_b;
end

