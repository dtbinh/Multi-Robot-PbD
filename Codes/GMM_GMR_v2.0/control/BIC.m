function result = BIC()
    load('data/raw_all.mat');
    tmp = raw_all';
    Data = tmp(4:6, :);
    numDemo = 3;
    [nbVar, nbData] = size(Data);
   


    in = [1:nbVar];
    max = 10;
    L = zeros(1,max);
    S = zeros(1,max);
    panlty = zeros(1, max);
    for nbStates = 1:max
            [Priors, Mu, Sigma] = model(Data, nbStates, numDemo);
        for j = 1 : nbData
            Pj = 0;
            for i=1:nbStates
                Pj = Pj + gaussPDF(Data(:, j), Mu(in,i), Sigma(in,in,i)) * Priors(i);
            end
            L(nbStates) = L(nbStates) + log(Pj);
        end
        np = (nbStates - 1) + nbStates*(nbVar + 0.5*nbVar*(nbVar+1));
        panlty(nbStates) = np/2 * log(nbData);
        S(nbStates) = -L(nbStates) + panlty(nbStates);
    end

  hold on;
  plot(L, 'g');
  plot(panlty, 'r');
  plot(S, 'b');
  A = S;
  result = find(A==((min(A))));
  
  pause;
  close all;
end