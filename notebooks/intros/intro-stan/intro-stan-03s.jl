### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 113eb996-f20b-11ea-297f-95379839995f
using Pkg, DrWatson

# ╔═╡ 113efaf8-f20b-11ea-343f-b39e12c4d457
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample
	using StanQuap
	using StatisticalRethinking
end

# ╔═╡ c705c7c4-f209-11ea-3651-a72bfc0f1756
md"## Intro-stan-03s.jl"

# ╔═╡ 12181d36-3e2f-11eb-1181-15fbfb7f7e42


# ╔═╡ 113f96ac-f20b-11ea-36c1-9b9b901c7af9
md"##### Define the Stan language model."

# ╔═╡ 114947f6-f20b-11ea-0ea5-0dfa3ef8191f
begin
	stan1_1 = "
	// Inferring a rate
	data {
	  int N;
	  int<lower=1> n;
	  int<lower=0> k[N];
	}
	parameters {
	  real<lower=0,upper=1> theta;
	}
	model {
	  // Prior distribution for θ
	  theta ~ uniform(0, 1);

	  // Observed Counts
	  k ~ binomial(n, theta);
	}"
end;

# ╔═╡ 29feebbc-0d8a-11eb-0cfe-fd90ac26ca49
begin
	N = 25                              # 25 experiments
	d = Binomial(9, 0.66)               # 9 tosses (simulate 2/3 is water)
	k = rand(d, N)                      # Simulate 15 trial results
	n = 9                               # Each experiment has 9 tosses
	data = Dict(:N => N, :n => n, :k => k)
	init = Dict(:theta => 0.5)
end;

# ╔═╡ 620e650e-f20b-11ea-1157-a3b90612c017
md"##### Create a quadratic approximation."

# ╔═╡ 114a04d4-f20b-11ea-0c10-e5c266f4ea8d
begin
	q1_1s, m1_1s, om = stan_quap("m1.1s", stan1_1; data, init)
	q1_1s
end

# ╔═╡ 115537b2-f20b-11ea-030c-478dea20fdbe
md"##### Describe the optimize result"

# ╔═╡ 11602dea-f20b-11ea-1243-fd37bbd57993
if !isnothing(om)
  om.optim
end

# ╔═╡ 914dbe76-8047-11eb-36aa-4161ca779950
PRECIS(read_samples(m1_1s; output_format=:dataframe))

# ╔═╡ 1160f5d8-f20b-11ea-317b-012bdf4d331f
md"## End of intro/intro-stan-03s.jl"

# ╔═╡ Cell order:
# ╟─c705c7c4-f209-11ea-3651-a72bfc0f1756
# ╠═12181d36-3e2f-11eb-1181-15fbfb7f7e42
# ╠═113eb996-f20b-11ea-297f-95379839995f
# ╠═113efaf8-f20b-11ea-343f-b39e12c4d457
# ╟─113f96ac-f20b-11ea-36c1-9b9b901c7af9
# ╠═114947f6-f20b-11ea-0ea5-0dfa3ef8191f
# ╠═29feebbc-0d8a-11eb-0cfe-fd90ac26ca49
# ╟─620e650e-f20b-11ea-1157-a3b90612c017
# ╠═114a04d4-f20b-11ea-0c10-e5c266f4ea8d
# ╟─115537b2-f20b-11ea-030c-478dea20fdbe
# ╠═11602dea-f20b-11ea-1243-fd37bbd57993
# ╠═914dbe76-8047-11eb-36aa-4161ca779950
# ╟─1160f5d8-f20b-11ea-317b-012bdf4d331f
