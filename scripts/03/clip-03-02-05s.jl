# # clip-02-05s.jl

using DrWatson
@quickactivate "StatisticalRethinkingStan"
using StatisticalRethinking

# ### snippet 3.2

p_grid = range(0, step=0.001, stop=1)
prior = ones(length(p_grid))
likelihood = [pdf(Binomial(9, p), 6) for p in p_grid]
posterior = likelihood .* prior
posterior = posterior / sum(posterior)
samples = sample(p_grid, Weights(posterior), length(p_grid));
samples[1:5]

# ### snippet 3.3
# Draw 10000 samples from this posterior distribution

N = 10000
samples2 = sample(p_grid, Weights(posterior), N);

# Store samples in an MCMCChains.Chains object. 

chn = MCMCChains.Chains(reshape(samples2, N, 1, 1), ["toss"]);

# Describe the chain

chn |> display

# Plot the chain

p1 = plot(chn)

# ### snippet 3.4

# Create a vector to hold the plots so we can later combine them

p2 = Vector{Plots.Plot{Plots.GRBackend}}(undef, 2)
p2[1] = density(samples, ylim=(0.0, 5.0), lab="Grid density")
p2[1] = density!(samples2, ylim=(0.0, 5.0), lab="Sample density")

# ### snippet 3.5

# Analytical calculation

w = 6
n = 9
x = 0:0.01:1
p2[2] = plot( x, pdf.(Beta( w+1 , n-w+1 ) , x ), lab="Conjugate solution")
p2[2] = density!(samples2, ylim=(0.0, 5.0), lab="Sample density")

# Add quadratic approximation

p3 = plot(p2..., layout=(1, 2))

density(samples2, lab="Sample2 density")
vline!(hpdi(samples2), lab="hpdi samples2")
vline!(quantile(samples2, [0.25, 0.75]), lab="quantiles [0.25, 0.75]")

# End of `03/clip-02-05s.jl`
