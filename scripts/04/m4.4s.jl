
using Markdown
using InteractiveUtils

using Pkg, DrWatson

begin
    @quickactivate "StatisticalRethinkingStan"
    using StanSample, StanOptimize
    using StatisticalRethinking
end

md"## Model m4.4s"

begin
    df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
    df = filter(row -> row[:age] >= 18, df);
    mean_weight = mean(df.weight)
    df.weight_c = df.weight .- mean_weight
end;

stan4_4 = "
data {
 int < lower = 1 > N;               // Sample size
 vector[N] height;                  // Outcome
 vector[N] weight_c;                // Predictor

 int N_new;                         // Number of predictions
 vector[N_new] x_new;               // Predict for x_new
}

parameters {
 real alpha;                        // Intercept
 real beta;                         // Slope (regression coefficients)
 real < lower = 0 > sigma;          // Error SD
}

model {
 height ~ normal(alpha + weight_c * beta , sigma);
}

generated quantities {
  vector[N_new] y_tilde;
  for (n in 1:N_new)
    y_tilde[n] = normal_rng(alpha + beta * x_new[n], sigma);
}
";

begin
	data = Dict(
		:N => length(df.height), :N_new => 5,
		:weight_c => df.weight_c, :height => df.height,
		:x_new => [-30, -10, 0, +10, +30]
	)
	init = Dict(:alpha => 170.0, :beta => 1.5, :sigma => 10.0)
end;			

begin
	q4_4s, m4_4s, om = quap("m4_4s", stan4_4; data, init)
	q4_4s
end

if !isnothing(m4_4s)
  chns4_4s = read_samples(m4_4s; output_format=:mcmcchains)
  Particles(chns4_4s)
end

begin
	quap4_4s_df = sample(q4_4s)				# DataFrame with samples
	first(quap4_4s_df, 10)					# First 10 rows
end

pred4_4s_df = stan_generate_quantities(m4_4s, 1)		# Use draws of chain 1 to simulate predictions

begin
	(ytilde, parameters) = read_generated_quantities(m4_4s)		# Read the generated quantities
	pred4_4s_df2 = DataFrame(ytilde[:, :, 1], parameters)		# Convert to a DataFrame
	PRECIS(pred4_4s_df2)										# Show summary
end

md"## End of m4.4s"
