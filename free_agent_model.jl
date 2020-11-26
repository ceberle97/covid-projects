### A Pluto.jl notebook ###
# v0.12.3

using Markdown
using InteractiveUtils

# ╔═╡ f1b48b82-0d42-11eb-1b6d-d9d2b22a730d
begin
	using Plots
	using Distributions
	using PlutoUI
	using LaTeXStrings
end

# ╔═╡ ff6d4228-0d42-11eb-04a0-df521925c5af
mutable struct Coordinate
	x::Number
	y::Number
end

# ╔═╡ 1160af06-0d43-11eb-0fe1-750eb2ac1377
function Base.:+(a::Coordinate, b::Coordinate)
	return Coordinate(a.x+b.x, a.y+b.y)
end

# ╔═╡ 40d4a40e-0d43-11eb-0a54-932a057dcda1
function Base.:-(a::Coordinate, b::Coordinate)
	return Coordinate(a.x-b.x, a.y-b.y)
end

# ╔═╡ fffe3a32-0d4a-11eb-18d1-ad2d7aec31f5
function Base.:(==)(a::Coordinate, b::Coordinate)
	if a.x == b.x && a.y == b.y
		return true
	else
		return false
	end
end

# ╔═╡ 52b668d8-0d43-11eb-3113-49ff09a742d3
function make_tuple(c::Coordinate)
	return (c.x, c.y)
end

# ╔═╡ 7a9df5c4-0d60-11eb-0474-c1444cd2f3a0
function make_coordinate(t::Tuple{Int64, Int64})
	return Coordinate(t[1], t[2])
end

# ╔═╡ 1c1278a2-0d44-11eb-29f9-257c8da9f9fa
function force_bounds(c::Coordinate, L::Number)
	c_new = Coordinate(c.x, c.y)
	if Base.abs(c.x) > L
		c_new.x = sign(c.x)*L
	end
	if Base.abs(c.y) > L
		c_new.y = sign(c.y)*L
	end
	return c_new
end

# ╔═╡ b058546a-0d43-11eb-0d90-7d3619d744b5
function force_bounds!(c::Coordinate, L::Number)
	if Base.abs(c.x) > L
		c.x = sign(c.x)*L
	end
	if Base.abs(c.y) > L
		c.y = sign(c.y)*L
	end
	return c
end

# ╔═╡ 37657906-0d44-11eb-0536-7be910979241
function place_rand(N::Number, L::Number)
	return force_bounds!.(Coordinate.(rand(-L:L, N), rand(-L:L, N)), L)
end

# ╔═╡ 80811f68-0d45-11eb-0d07-d5d3f1b47891
function visualise(coords::Array{Coordinate}, L::Number)
	p = plot(ratio = 1)
	scatter!(make_tuple.(coords), alpha=0.5, xticks=-L:L, yticks=-L:L, label="", xrotation=90)
	xlims!(-(L+1),(L+1))
	ylims!(-(L+1),(L+1))
	xlabel!(L"x")
	ylabel!(L"y")
	p
end

# ╔═╡ e82485b8-0d47-11eb-1a3a-d76d4239a412
@enum InfectionStatus S I R

# ╔═╡ e8c4dbbe-0d54-11eb-0c15-df1616f489a8
abstract type AbstractAgent end

# ╔═╡ ea105d6c-0d44-11eb-1744-83c8feb61441
mutable struct Agent <: AbstractAgent
	position::Coordinate
	status::InfectionStatus
end

# ╔═╡ 3f10677c-0d55-11eb-2579-ffd02ba2d5f3
mutable struct SocialAgent <: AbstractAgent
	position::Coordinate
	status::InfectionStatus
	sociability::Float64
end

# ╔═╡ 014c7934-0d49-11eb-28ab-7107e6c69cb1
function status(a::AbstractAgent)
	return a.status
end

# ╔═╡ 1f611e10-0d4a-11eb-0e04-03039f11973f
function position(a::AbstractAgent)
	return a.position
end

# ╔═╡ 94f9a1dc-0d49-11eb-1e27-6335e3372fac
function colour(a::AbstractAgent)
	if a.status == InfectionStatus(0)
		return "deepskyblue"
	elseif a.status == InfectionStatus(1)
		return "red"
	else
		return "darkolivegreen1"
	end
end

# ╔═╡ 80a47c90-0d56-11eb-159d-890fc0c339be
function sociability(agent::SocialAgent)
	return agent.sociability
end

# ╔═╡ 38f12e42-0d48-11eb-2a6c-1db07552cba4
function place_agents(N::Number, L::Number, num_infected=1, init_state=InfectionStatus(0))
	if num_infected > N || num_infected < 0
		throw(ArgumentError("\"num_infected\" must be positive semi-definite and smaller than \"N\""))
	end
	pos = place_rand(N, L) # get random positions
	agents = Agent.(pos, init_state) # place agents on the grid
	for i in 1:num_infected
		rem_agents = agents[status.(agents) .== init_state]
		rand(rem_agents).status = InfectionStatus(1)
	end
	return agents
end

# ╔═╡ 839617ac-0d55-11eb-39f2-8111e3fe3da7
function place_social_agents(N::Number, L::Number, sociability, num_infected=1, init_state=InfectionStatus(0))
	if num_infected > N || num_infected < 0
		throw(ArgumentError("\"num_infected\" must be positive semi-definite and smaller than \"N\""))
	end
	pos = place_rand(N, L) # get random positions
	agents = SocialAgent.(pos, init_state, sociability) # place agents on the grid
	if num_infected == 0
		return agents
	else
		for i in 1:num_infected
			rem_agents = agents[status.(agents) .== init_state]
			rand(rem_agents).status = InfectionStatus(1)
		end
	end
	return agents
end

# ╔═╡ 6fab84aa-0d48-11eb-1cae-c14c04d93039
function visualise(agents::Array, L::Number)
	p = plot(ratio = 1)
	ag = agents[typeof.(agents) .== Agent]
	sag = agents[typeof.(agents) .== SocialAgent]
	scatter!(make_tuple.(position.(ag)), alpha=1, xticks=-L:L, yticks=-L:L, label="", xrotation=90, color=colour.(ag))
	scatter!(make_tuple.(position.(sag)), alpha=(1 .+sociability.(sag))./2, xticks=-L:L, yticks=-L:L, label="", xrotation=90, color=colour.(sag), marker=:hexagon)
	xlims!(-(L+1),(L+1))
	ylims!(-(L+1),(L+1))
	xlabel!(L"x")
	ylabel!(L"y")
	p
end

# ╔═╡ 9428b044-0d4a-11eb-06c4-655ee1ca72c8
struct Disease
	p_infect::Float64
	p_recovery::Float64
end

# ╔═╡ 0dfe0be0-0d4a-11eb-0476-d1d31c332b71
function interact!(victim::AbstractAgent, source::AbstractAgent, disease::Disease)
	if victim.position == source.position
		if source.status == InfectionStatus(1) && victim.status == InfectionStatus(0)
			if disease.p_infect > rand()
				victim.status = InfectionStatus(1)
			end
		end
	end
	if source.status == InfectionStatus(1)
		if disease.p_recovery > rand()
			source.status = InfectionStatus(2)
		end
	end
end

# ╔═╡ a0ff0a2e-0d4b-11eb-2a99-69f2cb3a5076
function eval_sir(agents::Array)
	s = length(agents[status.(agents) .== InfectionStatus(0)])
	i = length(agents[status.(agents) .== InfectionStatus(1)])
	r = length(agents[status.(agents) .== InfectionStatus(2)])
	return (s,i,r)
end

# ╔═╡ 7b4c5b5a-0d4c-11eb-1bdb-972c55288057
possible_moves = [(1,0),(0,1),(-1,0), (0,-1)]

# ╔═╡ 52812e22-0d5a-11eb-2140-5bf13871ab14
possible_moves_co = [Coordinate(1,0), Coordinate(0,1), Coordinate(-1,0), Coordinate(0, -1)]

# ╔═╡ 91742ba6-0d4c-11eb-0ab9-f5f92abcbd91
function move!(agent::AbstractAgent, step::Tuple{Int64, Int64}, L::Number)
	agent.position = force_bounds(agent.position+Coordinate(step[1], step[2]), L)
	return agent
end

# ╔═╡ 09ad4888-0d4c-11eb-206d-0b9e26f82801
function step!(agents::Array, L::Number, disease::Disease)
	source_ind = rand(1:length(agents))
	source = agents[source_ind]
	if typeof(source) == SocialAgent
		neighbours = fill(source.position, 4) .+ possible_moves_co
		slices = [n in position.(agents) for n in neighbours]
		ξ = rand()
		if true in slices && false in slices
			if ξ < source.sociability
				m = unique(make_tuple.(force_bounds.(neighbours[slices], L)))
			else
				m = unique(make_tuple.(force_bounds.(neighbours[.!slices], L)))
			end
			filter!(e->e≠make_tuple(source.position), m)
			if length(m) != 0
				target = rand(m)
				Δ = make_coordinate(target) - source.position
				Δ.x *= sign(source.position.x)*sign(make_coordinate(target).x)
				Δ.y *= sign(source.position.y)*sign(make_coordinate(target).y)
				move!(source, make_tuple(Δ), L)
			else
				move!(source, rand(possible_moves), L)
			end
		else
			move!(source, rand(possible_moves), L)
		end
	else
		move!(source, rand(possible_moves), L)
	end
	interact!.(agents[1:end .!= source_ind], fill(source, length(agents)-1), fill(disease, length(agents)-1))
	return agents
end

# ╔═╡ 3878cc14-0d51-11eb-39dc-67395c08585c
begin
	L = 7
	N = 55
	M = 13
	σ=0.2
	Tmax = 500
	pandemic = Disease(0.45, 0.0001)
end

# ╔═╡ 0d852e06-0d4e-11eb-2b57-ab6ecaa8ed22
begin
	ag = convert(Array{AbstractAgent}, place_social_agents(M, L, 0.1))
	append!(ag, place_agents(N, L))
	Ss = []
	Is = []
	Rs = []
	@gif for t in 1:Tmax
		for i in 1:1N
            step!(ag, L, pandemic)
        end
		left = visualise(ag, L)
		right = plot(xlim=(1,Tmax), ylim=(1,N), size=(600,300))
		S,I,R = eval_sir(ag)
		push!(Ss, S)
		push!(Rs, R)
		push!(Is, I)
		plot!(right, 1:t, Ss, label="S")
        plot!(right, 1:t, Is, label="I")
        plot!(right, 1:t, Rs, label="R")
		plot(left, right)
	end
end

# ╔═╡ 033d5ffc-0d5f-11eb-050a-33cfbd5edda4
begin
	a1 = Agent(Coordinate(2,2), InfectionStatus(0))
	a2 = Agent(Coordinate(2,1), InfectionStatus(1))
	neighbours = fill(a1.position, 4) .+ possible_moves_co
	slices = [n in position.([a2]) for n in neighbours]
	m = unique(make_tuple.(force_bounds.(neighbours[.!slices], 2)))
	filter!(e->e≠make_tuple(a1.position), m)
	Δ = make_coordinate(rand(m)) - a1.position
	Δ.x *= sign(a1.position.x)*sign(make_coordinate(rand(m)).x)
	move!(a1, make_tuple(Δ), 2)
	visualise([a1, a2], 2)
	#t = unique(make_tuple.(force_bounds!.(neighbours[.!slices], 2)))
	#filter!(e->e≠make_tuple(a1.position),t)
	#a1.position
	#t .!= a1.position
end

# ╔═╡ Cell order:
# ╟─f1b48b82-0d42-11eb-1b6d-d9d2b22a730d
# ╟─ff6d4228-0d42-11eb-04a0-df521925c5af
# ╟─1160af06-0d43-11eb-0fe1-750eb2ac1377
# ╟─40d4a40e-0d43-11eb-0a54-932a057dcda1
# ╟─fffe3a32-0d4a-11eb-18d1-ad2d7aec31f5
# ╟─52b668d8-0d43-11eb-3113-49ff09a742d3
# ╟─7a9df5c4-0d60-11eb-0474-c1444cd2f3a0
# ╟─1c1278a2-0d44-11eb-29f9-257c8da9f9fa
# ╟─b058546a-0d43-11eb-0d90-7d3619d744b5
# ╟─37657906-0d44-11eb-0536-7be910979241
# ╟─80811f68-0d45-11eb-0d07-d5d3f1b47891
# ╟─e82485b8-0d47-11eb-1a3a-d76d4239a412
# ╠═e8c4dbbe-0d54-11eb-0c15-df1616f489a8
# ╠═ea105d6c-0d44-11eb-1744-83c8feb61441
# ╠═3f10677c-0d55-11eb-2579-ffd02ba2d5f3
# ╟─014c7934-0d49-11eb-28ab-7107e6c69cb1
# ╟─1f611e10-0d4a-11eb-0e04-03039f11973f
# ╟─94f9a1dc-0d49-11eb-1e27-6335e3372fac
# ╟─80a47c90-0d56-11eb-159d-890fc0c339be
# ╠═38f12e42-0d48-11eb-2a6c-1db07552cba4
# ╠═839617ac-0d55-11eb-39f2-8111e3fe3da7
# ╠═6fab84aa-0d48-11eb-1cae-c14c04d93039
# ╠═9428b044-0d4a-11eb-06c4-655ee1ca72c8
# ╠═0dfe0be0-0d4a-11eb-0476-d1d31c332b71
# ╠═a0ff0a2e-0d4b-11eb-2a99-69f2cb3a5076
# ╠═7b4c5b5a-0d4c-11eb-1bdb-972c55288057
# ╠═52812e22-0d5a-11eb-2140-5bf13871ab14
# ╠═91742ba6-0d4c-11eb-0ab9-f5f92abcbd91
# ╠═09ad4888-0d4c-11eb-206d-0b9e26f82801
# ╠═3878cc14-0d51-11eb-39dc-67395c08585c
# ╠═0d852e06-0d4e-11eb-2b57-ab6ecaa8ed22
# ╠═033d5ffc-0d5f-11eb-050a-33cfbd5edda4
