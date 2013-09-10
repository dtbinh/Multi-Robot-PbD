function result = BIC(Data, maxStates)

    [nbVar, nbData] = size(Data);
    in = [1:nbVar];
    L = zeros(1,maxStates);
    S = zeros(1,maxStates);
    panlty = zeros(1, maxStates);
    for nbStates = 1:maxStates
            fprintf('test nbStates %d\n', nbStates);
            [Priors, Mu, Sigma] = GMM(Data, nbStates);
        for j = 1 : nbData
            Pj = 0;
            for i=1:nbStates
                Pj = Pj + gaussPDF(Data(:, j), Mu(in,i), Sigma(in,in,i)) * Priors(i);
            end
            L(nbStates) = L(nbStates) + log(Pj);
        end
        np = (nbStates - 1) + nbStates*(nbVar + 0.5*nbVar*(nbVar+1));
        panlty(nbStates) = np / 2 * log(nbData);
        S(nbStates) = - L(nbStates) + panlty(nbStates);
    end

  hold on;
  plot(-L, 'g');
  plot(panlty, 'r');
  plot(S, 'b');
  A = S;
  result = find(A==((min(A))));
  
end