### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 3bd0847c-f2b4-11ea-35d8-c7657a170cf9
using DrWatson

# ╔═╡ 3bd0c52c-f2b4-11ea-09e6-05dbd556433f
begin
	@quickactivate "StatisticalRethinkingStan"
	using StatisticalRethinking
	using PlutoUI
end

# ╔═╡ 28342aca-f2b1-11ea-342d-95590e306ff4
md"## Clip-04-01-05s.jl"

# ╔═╡ 3bd18872-f2b4-11ea-2271-470ff5d51737
md"### snippet 4.1"

# ╔═╡ 3be20a12-f2b4-11ea-2179-2995ca45302f
md"###### No attempt has been made to condense this too fewer lines of code."

# ╔═╡ 4114e7b0-f85f-11ea-248a-e1c6723d2f1a
@bind noofwalks Slider(5:200, default=9)

# ╔═╡ 3be2d1ea-f2b4-11ea-09ce-1db161f69c7e
begin
	noofsteps = 20;
	pos = Array{Float64, 2}(rand(Uniform(-1, 1), noofsteps, noofwalks));
	pos[1, :] = zeros(noofwalks);
	csum = cumsum(pos, dims=1);
	mx = minimum(csum) * 0.9
end;

# ╔═╡ 3bf08696-f2b4-11ea-0fae-815209e20f46
md"###### Plot and annotate the random walks."

# ╔═╡ 3bfe421a-f2b4-11ea-12c7-f7f775c210a9
md"###### Generate 3 plots of densities at 3 different step numbers (4, 8 and 16)."

# ╔═╡ 3bff112a-f2b4-11ea-338a-791bc65b719f
begin
	f = Plots.font("DejaVu Sans", 6)
	xtick_pos = [5, 9, 17]
	xtick_labels = ("step 4","step 8","step 16")
	fig1 = plot(csum, leg=false, xticks=(xtick_pos,xtick_labels),
		title="No of random walks = $(noofwalks)")
	plot!(fig1, csum[:, Int(floor(noofwalks/2))], leg=false, color=:black)
	for (i, tick_pos) in enumerate(xtick_pos)
		plot!(fig1, [tick_pos], seriestype="vline")
	end

	fig2 = Vector{Plots.Plot{Plots.GRBackend}}(undef, 3);
	plt = 1
	for step in [4, 8, 16]
		indx = step + 1 								# We added the first line of zeros
		global plt
	  	fitl = fit_mle(Normal, csum[indx, :])
	  	lx = (fitl.μ-4*fitl.σ):0.01:(fitl.μ+4*fitl.σ)
	  	fig2[plt] = density(csum[indx, :], legend=false, title="$(step) steps")
	 	plot!( fig2[plt], lx, pdf.(Normal( fitl.μ , fitl.σ ) , lx ), fill=(0, .5,:orange))
	  	plt += 1
	end
	fig3 = plot(fig2..., layout=(1, 3))
	plot(fig1, fig3, layout=(2,1))
end

# ╔═╡ 3c10cb0e-f2b4-11ea-210f-1f6986fbb7d8
md"## snippet 4.2"

# ╔═╡ 3c1b683e-f2b4-11ea-206b-b9178296ec19
prod(1 .+ rand(Uniform(0, 0.1), 12))

# ╔═╡ 3c248840-f2b4-11ea-1397-9f2c313a2676
md"## snippet 4.3"

# ╔═╡ 3c26427c-f2b4-11ea-23f9-6303c62de7f6
begin
	growth = [prod(1 .+ rand(Uniform(0, 0.1), 12)) for i in 1:10000];
	fit2 = fit_mle(Normal, growth)
	plot(Normal(fit2.μ , fit2.σ ), fill=(0, .5,:orange), lab="Normal distribution")
	density!(growth, lab="'sample' distribution")
end

# ╔═╡ 3c37aa58-f2b4-11ea-2e87-a11117582011
md"## snippet 4.4"

# ╔═╡ 3c390506-f2b4-11ea-3232-296f6952aaa7
begin
	big = [prod(1 .+ rand(Uniform(0, 0.5), 12)) for i in 1:10000];
	small = [prod(1 .+ rand(Uniform(0, 0.01), 12)) for i in 1:10000];
	fitb = fit_mle(Normal, big)
	fits = fit_mle(Normal, small)
	p5 = plot(Normal(fitb.μ , fitb.σ ), lab="Big normal distribution", fill=(0, .5,:orange))
	p4 = plot(Normal(fits.μ , fits.σ ), lab="Small normal distribution", fill=(0, .5,:orange))
	density!(p5, big, lab="'big' distribution")
	density!(p4, small, lab="'small' distribution")
	plot(p5, p4, layout=(1, 2))
end

# ╔═╡ 3c4245ee-f2b4-11ea-2add-750014544e83
md"## snippet 4.5"

# ╔═╡ 3c4be516-f2b4-11ea-086b-f1461fa2e55e
begin
	log_big = [log(prod(1 .+ rand(Uniform(0, 0.5), 12))) for i in 1:10000];
	fit3 = fit_mle(Normal, log_big)
	plot(Normal(fit3.μ , fit3.σ ), fill=(0, .5,:orange), lab="Normal distribution")
	density!(log_big, lab="'sample' distribution")
end

# ╔═╡ 3d1db2f0-f2b4-11ea-3bde-29b8f0be3087
md"## End of clip-04-01-05s.jl"

# ╔═╡ Cell order:
# ╟─28342aca-f2b1-11ea-342d-95590e306ff4
# ╠═3bd0847c-f2b4-11ea-35d8-c7657a170cf9
# ╠═3bd0c52c-f2b4-11ea-09e6-05dbd556433f
# ╟─3bd18872-f2b4-11ea-2271-470ff5d51737
# ╟─3be20a12-f2b4-11ea-2179-2995ca45302f
# ╠═4114e7b0-f85f-11ea-248a-e1c6723d2f1a
# ╠═3be2d1ea-f2b4-11ea-09ce-1db161f69c7e
# ╟─3bf08696-f2b4-11ea-0fae-815209e20f46
# ╟─3bfe421a-f2b4-11ea-12c7-f7f775c210a9
# ╠═3bff112a-f2b4-11ea-338a-791bc65b719f
# ╟─3c10cb0e-f2b4-11ea-210f-1f6986fbb7d8
# ╠═3c1b683e-f2b4-11ea-206b-b9178296ec19
# ╠═3c248840-f2b4-11ea-1397-9f2c313a2676
# ╠═3c26427c-f2b4-11ea-23f9-6303c62de7f6
# ╟─3c37aa58-f2b4-11ea-2e87-a11117582011
# ╠═3c390506-f2b4-11ea-3232-296f6952aaa7
# ╟─3c4245ee-f2b4-11ea-2add-750014544e83
# ╠═3c4be516-f2b4-11ea-086b-f1461fa2e55e
# ╟─3d1db2f0-f2b4-11ea-3bde-29b8f0be3087
