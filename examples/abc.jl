using CoherentStructures

abcctx = CoherentStructures.regularTriangularGrid3D((25,25,25),[0.0,0.0,0.0],
    [2π,2π,2π],quadrature_order=1 )
bdata_predicate = (x,y) -> (CoherentStructures.distmod(x[1],y[1],2π) < 1e-9 && CoherentStructures.distmod(x[2],y[2],2π)<1e-9 &&
    CoherentStructures.distmod(x[3],y[3],2π) <1e-9)
bdata = boundaryData(abcctx,bdata_predicate)

cgfun = x-> mean_diff_tensor(CoherentStructures.abcFlow,x,[0.0,1.0], 1.e-10,tolerance= 1.e-3)
@time M = assembleMassMatrix(abcctx,bdata=bdata);
@time K = assembleStiffnessMatrix(abcctx,cgfun,bdata=bdata)
@time λ, V = eigs(K,M,which=:SM,nev=10)

plot_real_spectrum(λ)

### Plotting in 2D

u  = undoBCS(abcctx,V[:,2],bdata)
u /= maximum(abs.(u))
for z in linspace(0,2π,10)
    xs = linspace(0,2π,50)
    ys = linspace(0,2π,50)
    Plots.display(
        Plots.heatmap(xs,ys,
        (x,y) -> evaluate_function_from_dofvals(abcctx,u, [x,y,z]),
        title="z = $z",clim=(-1,1)
    ))
end

### Plotting in 3D
xs = linspace(0,2π,25)
u = undoBCS(abcctx,V[:,5],bdata)
vals = [evaluate_function_from_dofvals(
    abcctx,u,[x,y,z]) for x in xs, y in xs, z in xs]

using Makie
scene = Scene()
volume(vals, algorithm = :iso,isovalue=0.5*maximum(vals))
center!(scene)
