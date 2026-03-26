
# Benchmarks

```@example bench1
using ARSampling: ARSampler, Objective, sample!
using DifferentiationInterface, Distributions
using ForwardDiff
using Chairmarks
using Mooncake

# Define function to sample from
f(x) = logpdf(Laplace(0., 0.5), x) + logpdf(Normal(0.0, 2.0), x)
```

### ARSampling.jl -- ForwardDiff.jl

```@example bench1
sam = ARSampler(Objective(f), [-0.5, 0.5], (-Inf, Inf))

@be deepcopy(sam) sample!(_, 100000, true, 25) samples=100 evals=1 seconds=1000
```

```@example bench1
sam = ARSampler(Objective(f; adbackend = AutoMooncake()), [-0.5, 0.5], (-Inf, Inf))

@be deepcopy(sam) sample!(_, 100000, true, 25) samples=100 evals=1 seconds=1000
```

