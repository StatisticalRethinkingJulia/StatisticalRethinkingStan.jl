### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ d2ce3d8a-fdc0-11ea-0920-6fd0ca7c09be
using Pkg, DrWatson

# ╔═╡ d2ce824a-fdc0-11ea-1504-a7f6289a0308
begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanQuap
	using StatisticalRethinking
end

# ╔═╡ 37a0fd70-fdc0-11ea-3fa2-4968a27d3d35
md"## Clip-05-44s.jl"

# ╔═╡ d2cf0594-fdc0-11ea-37c8-9d589bcc4b7b
md"### snippet 5.44"

# ╔═╡ d2de0dbe-fdc0-11ea-3cc5-dd8dc2417134
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';');
	df = filter(row -> row[:age] > 18, df)
	scale!(df, [:height, :weight])
end;

# ╔═╡ d2deae40-fdc0-11ea-0e50-0fc462ae5deb
stan5_8 = "
data{
    int N;
    int male[N];
    vector[N] age;
    vector[N] weight;
    vector[N] height;
    int sex[N];
}
parameters{
    vector[2] a;
    real<lower=0> sigma;
}
model{
    vector[N] mu;
    sigma ~ exponential(1);
    a ~ normal( 178 , 20 );
    for ( i in 1:N ) {
        mu[i] = a[sex[i]];
    }
    height ~ normal( mu , sigma );
}
";

# ╔═╡ d2ea2a4a-fdc0-11ea-2dab-27a0b544fb0e
md"### Define the SampleModel, etc."

# ╔═╡ d2eac996-fdc0-11ea-0ab9-09ab8a1bcdca
begin
	df[!, :sex] = [df[i, :male] == 1 ? 2 : 1 for i in 1:size(df, 1)]
	df_m = filter(row -> row[:sex] == 2, df)
	df_f = filter(row -> row[:sex] == 1, df)
	data = (N = size(df, 1), male = df.male, weight = df.weight,
		height = df.height, age = df.age, sex = df.sex)
	q5_8s, m5_8s, o5_8s = stan_quap("m5.8", stan5_8; data);
	post5_8s_df = read_samples(m5_8s; output_format=:dataframe)
	PRECIS(post5_8s_df)
end

# ╔═╡ d2f648e8-fdc0-11ea-11a6-8d47151362d8
if !isnothing(m5_8s)
	part5_8s = Particles(post5_8s_df)
end

# ╔═╡ 6a3e68b2-31a0-11eb-0420-cfa73a6e8f35
begin
	quap5_8s_df = sample(q5_8s)
	PRECIS(quap5_8s_df)
end

# ╔═╡ d30451e0-fdc0-11ea-2c62-9f4cfd82f8fd
if !isnothing(m5_8s)
	plot(title="Densities by sex")
	density!(df_m.height, lab="Male")
	density!(df_f.height, lab="Female")
	vline!([mean(part5_8s[Symbol("a.1")])], lab="Female mean estimate")
	vline!([mean(part5_8s[Symbol("a.2")])], lab="Male mean estimate")
	vline!([mean(quap5_8s_df[:, Symbol("a.2")])], lab="Male (quap) mean estimate")
end

# ╔═╡ d304f5a0-fdc0-11ea-2651-4db63a66bd53
md"## End of clip-05-44s.jl"

# ╔═╡ Cell order:
# ╟─37a0fd70-fdc0-11ea-3fa2-4968a27d3d35
# ╠═d2ce3d8a-fdc0-11ea-0920-6fd0ca7c09be
# ╠═d2ce824a-fdc0-11ea-1504-a7f6289a0308
# ╟─d2cf0594-fdc0-11ea-37c8-9d589bcc4b7b
# ╠═d2de0dbe-fdc0-11ea-3cc5-dd8dc2417134
# ╠═d2deae40-fdc0-11ea-0e50-0fc462ae5deb
# ╟─d2ea2a4a-fdc0-11ea-2dab-27a0b544fb0e
# ╠═d2eac996-fdc0-11ea-0ab9-09ab8a1bcdca
# ╠═d2f648e8-fdc0-11ea-11a6-8d47151362d8
# ╠═6a3e68b2-31a0-11eb-0420-cfa73a6e8f35
# ╠═d30451e0-fdc0-11ea-2c62-9f4cfd82f8fd
# ╟─d304f5a0-fdc0-11ea-2651-4db63a66bd53
