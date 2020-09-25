# m6.6s.jl

using Pkg, DrWatson

begin
  @quickactivate "StatisticalRethinkingStan"
  using StanSample
  using StatisticalRethinking
end

begin
  N = 100
  df = DataFrame(
    :h0 => rand(Normal(10,2 ), N),
    :treatment => vcat(zeros(Int, Int(N/2)), ones(Int, Int(N/2)))
  );
  df[!, :fungus] = [rand(Binomial(1, 0.5 - 0.4 * df[i, :treatment]), 1)[1] for i in 1:N]
  df[!, :h1] = [df[i, :h0] + rand(Normal(5 - 3 * df[i, :fungus]), 1)[1] for i in 1:N]
  scale!(df, [:h0, :treatment, :fungus, :h1])
end

sim_p = DataFrame(:sim_p => rand(LogNormal(0, 0.25), 10000))

m6_6 = "
data {
  int <lower=1> N;
  vector[N] h0;
  vector[N] h1;
}
parameters{
  real<lower=0> p;
  real<lower=0> sigma;
}
model {
  vector[N] mu;
  p ~ lognormal(0, 0.25);
  sigma ~ exponential(1);
  mu = h0 * p;
  h1 ~ normal(mu, sigma);
}
";

m6_6_data = Dict(
  :N => nrow(df),
  :h0 => df[:, :h0],
  :h1 => df[:, :h1]
)
m6_6s = SampleModel("m6.6s", m6_6)
rc = stan_sample(m6_6s; data=m6_6_data)

if success(rc)
  dfa6_6 = read_samples(m6_6s; output_format=:dataframe);
  p6_6 = Particles(dfa6_6)
end

# End of m6.6s.jl