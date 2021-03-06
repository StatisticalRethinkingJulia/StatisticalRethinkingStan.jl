# m5.4.MAs.jl

using Pkg, DrWatson
@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

# ### snippet 5.1

df = CSV.read(sr_datadir("WaffleDivorce.csv"), DataFrame);

df = DataFrame(
  :A => df[:, :MedianAgeMarriage],
  :M => df[:, :Marriage],
  :D => df[:, :Divorce]
 )

scale!(df, [:M, :A, :D])

# Define the Stan language model

stan5_4_MA = "
data {
  int N;
  vector[N] A;
  vector[N] M;
}
parameters {
  real a;
  real bMA;
  real<lower=0> sigma;
}
model {
  vector[N] mu = a + bMA * A;
  a ~ normal( 0 , 0.2 );
  bMA ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  M ~ normal( mu , sigma );
}
";

# Define the SampleModel
m5_4_MAs = SampleModel("m5.4", stan5_4_MA);

# Input data

m5_4_data = Dict(
  "N" => size(df, 1), 
  "M" => df[:, :M_s],
  "A" => df[:, :A_s] 
);

# Sample using cmdstan

rc5_4_MAs = stan_sample(m5_4_MAs, data=m5_4_data);

if success(rc5_4_MAs)

  # Rethinking results

  rethinking_results = "
           mean   sd  5.5% 94.5%
    a      0.00 0.09 -0.14  0.14
    bMA   -0.69 0.10 -0.85 -0.54
    sigma  0.68 0.07  0.57  0.79
  ";

  part5_4_MAs = read_samples(m5_4_MAs; output_format=:particles)
  part5_4_MAs |> display

end

# End of m5.4.MAs.jl