# m6_11s.jl

using Pkg, DrWatson

@quickactivate "StatisticalRethinkingStan"
using StanSample
using StatisticalRethinking

N = 200
b_GP = 1                               # Direct effect of G on P
b_GC = 0                               # Direct effect of G on C
b_PC = 1                               # Direct effect of P on C
b_U = 2                                # Direct effect of U on P and C

df = DataFrame(
  :u => 2 * rand(Bernoulli(0.5), N) .- 1,
  :g => rand(Normal(), N)
)

df[!, :p] = [rand(Normal(b_GP * df[i, :g] + b_U * df[i, :u]), 1)[1] for i in 1:N]
df[!, :c] = [rand(Normal(b_PC * df[i, :p] + b_GC * df[i, :g] + b_U * df[i, :u]), 1)[1] for i in 1:N]

precis(df)

stan6_11 = "
data {
  int <lower=0> N;
  vector[N] C;
  vector[N] P;
  vector[N] G;
}
parameters {
  real <lower=0> sigma;
  real a;
  real b_PC;
  real b_GC;
}
model {
  vector[N] mu;
  sigma ~ exponential(1);
  a ~ normal(0, 1);
  b_PC ~ normal(0, 1);
  b_GC ~ normal(0, 1);
  mu = a + b_PC * P + b_GC * G;
  C ~ normal(mu, sigma);
}
";

m6_11s = SampleModel("m6.11s", stan6_11)
m6_11_data = Dict(:N => nrow(df), :C => df.c, :P => df.p, :G => df.g)
rc6_11s = stan_sample(m6_11s, data=m6_11_data)

if success(rc6_11s)
  part6_11s = read_samples(m6_11s, output_format=:particles)
  part6_11s |> display
end

# End of m6.11s.jl
