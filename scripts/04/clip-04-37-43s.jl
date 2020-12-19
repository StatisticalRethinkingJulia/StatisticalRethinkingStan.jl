
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
	@quickactivate "StatisticalRethinkingStan"
	using StanSample, StanOptimize
	using StatisticalRethinking
end

md"## Clip-04-37-43s.jl"

md"### snippet 4.37"

begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame)
	df = filter(row -> row[:age] >= 18, df);
	mean_weight = mean(df.weight);
	df.weight_c = df.weight .- mean_weight;
end;

md"### snippet 4.38"

md"##### Define the Stan language models."

stan4_4a = "
parameters {
 real alpha;                       // Intercept
 real beta;                        // Slope (regression coefficients)
}

model {
	alpha ~ normal(178, 20);
	beta ~ normal(0, 10);
}
";

stan4_4b = "
parameters {
 real alpha;                       // Intercept
 real beta;                        // Slope (regression coefficients)
}

model {
	alpha ~ normal(178, 20);
	beta ~ lognormal(0, 1);
}
";

md"##### Compute quadratic approximations."

begin
	init = Dict(:alpha => 170.0, :beta => 2.0)
	q4_4as, _, _ = quap("m4.4as", stan4_4a; init)
	quap4_4as_df = sample(q4_4as)
	q4_4bs, _, _ = quap("m4.4bs", stan4_4b; init)
	quap4_4bs_df = sample(q4_4bs)
end;|

PRECIS(quap4_4as_df)

PRECIS(quap4_4bs_df)

md"## snippet 4.40"

begin
	density(rand(LogNormal(0, 1), 4000))
end

md"### snippets 4.39 & 4.41"

if !isnothing(q4_4as) && !isnothing(q4_4bs)
	x = range(30.0, stop=70.0, length=50)
	xbar = mean(x)
	fig1 = plot(ylab="height [cm]", xlab="weight [kg]", ylim=(-100, 400),
		leg=false, title="beta ~ Normal(0, 10)")
	for i in 1:100
		fig1 = plot!(x, quap4_4as_df.alpha[i] .+ quap4_4as_df.beta[i] .* (x .- xbar), color=:grey)
	end
	fig2 = plot(ylab="height [cm]", xlab="weight [kg]", ylim=(-100, 400), 
		leg=false, title="beta ~ LogNormal(0, 1)")
	for i in 1:100
		fig2 = plot!(x, quap4_4bs_df.alpha[i] .+ quap4_4bs_df.beta[i] .* (x .- xbar), color=:grey)
	end
	hline!(fig1, [0.0, 272.0], width=3)
	annotate!(fig1, [(30.0, 10.0, Plots.text("Embryo", 6, :red, :left))])
	annotate!(fig1, [(30.0, 280.0, Plots.text("World's largest person (272 cm)", 6, :red, :left))])

	hline!(fig2, [0.0, 272.0], width=3)
	annotate!(fig2, [(30.0, 10.0, Plots.text("Embryo", 6, :red, :left))])
	annotate!(fig2, [(30.0, 280.0, Plots.text("World's largest person (272 cm)", 6, :red, :left))])

	plot(fig1, fig2, layout=(1, 2))
end

stan4_4c = "
parameters {
 real alpha;                       // Intercept
 real log_beta;                    // Slope (regression coefficients)
}

model {
	alpha ~ normal(178, 40);
	log_beta ~ normal(0, 1);
}
";

begin
	q4_4cs, sm, om = quap("m4.4cs", stan4_4c; init)
	quap4_4cs_df = sample(q4_4cs)
	PRECIS(quap4_4cs_df)
end

if !isnothing(q4_4as) && !isnothing(q4_4bs)
	fig3 = plot(ylab="height [cm]", xlab="weight [kg]", ylim=(-100, 400), 
		leg=false, title="log_beta ~ Normal(0, 1)")
	for i in 1:100
		fig3 = plot!(x, quap4_4cs_df.alpha[i] .+ 
			exp(quap4_4cs_df.log_beta[i]) .* (x .- xbar), color=:grey)
	end

	hline!(fig3, [0.0, 272.0], width=3)
	annotate!(fig3, [(30.0, 10.0, Plots.text("Embryo", 6, :red, :left))])
	annotate!(fig3, [(30.0, 280.0, Plots.text("World's largest person (272 cm)", 6, :red, :left))])

	plot(fig2, fig3, layout=(1, 2))
end

md"# End of clip-04-37-43s.jl"
