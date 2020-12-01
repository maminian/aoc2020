# mandelbrot
using Plots

n = 128
maxit = 1000

# set up grid
x = range(-2,2,length=n)      # real part
y = range(-2,2,length=n)  # imag part
z = x' .+ im*y

I = zeros(Int64,n,n)
val = zeros(Complex,n,n)

mask = abs.(val) .< 2

for i=1:maxit
    global val = val.^2 .+ z
    global mask = mask.*(abs.(val) .< 2)
    global I += mask
end

heatmap(x,y,log10.(I.+1) , aspect_ratio=1)
xlims!(minimum(x),maximum(x))
ylims!(minimum(y),maximum(y))
