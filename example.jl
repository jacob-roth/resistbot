##
## example output
##

include("preprocess.jl")

x  = readdlm("state_strings.csv", ',')
y  = readdlm("city_strings.csv", ',')

xk = x[:,1]
xv = x[:,2]
xd = Dict(xk .=> xv)

yk = y[:,1]
yv = y[:,2]
yd = Dict(yk .=> yv)

println(xd["Colorado"])
println(yd["Chicago"])
println(yd["Baton Rouge"])