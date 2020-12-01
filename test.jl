# test test 
using Plots


x = range(-8,8,length=80)
y = range(-8,8,length=80)

r = (x'.^2 .+ y.^2).^0.5
th = atan.( y, x')

Z = cos.(r .+ 4*th)

contour(x,y,Z, levels=11, fill=true, aspect_ratio=1)
xlims!(-8,8)
ylims!(-8,8)
