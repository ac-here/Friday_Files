function Y = compute_exponential(X, X0, Y0, Tau, Pinf)
    Y = Pinf + (Y0 - Pinf) * exp(- (X - X0)/Tau);
end