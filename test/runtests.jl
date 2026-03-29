using ARSampling: ARSampler, Objective, sample!
using DifferentiationInterface
using ForwardDiff
using Mooncake
using Enzyme
using SpecialFunctions: loggamma
using Random
using Test
using JET

function test_density(x, k = 3, n = 20)
    alpha = exp(x)
    return x +
        x * (k - 3 / 2) +
        (-1 / (2 * alpha)) +
        loggamma(alpha) -
        loggamma(n + alpha)
end

const n_samples = 1000_000

@testset "Autodiff backends" begin
    @testset "ForwardDiff" begin
        let
            sam = ARSampler(Objective(test_density; adbackend = AutoForwardDiff()), (-Inf, Inf))
            obj_big = Objective(test_density, one(BigFloat); adbackend = AutoForwardDiff())
            sam_big = ARSampler(obj_big, (-Inf, Inf))
            # Setup samples
            sam_2 = deepcopy(sam)
            Random.seed!(1)
            samples = sample!(sam, n_samples)
            Random.seed!(1)
            samples_2 = sample!(sam_2, n_samples)

            # Tests
            @test samples isa Vector{Float64}
            @test length(samples) == n_samples
            @test samples == samples_2 # Try to catch uninitialized memory

            # JET
            @test_opt Objective(test_density; adbackend = AutoForwardDiff())
            obj_jet = Objective(test_density; adbackend = AutoForwardDiff())
            @test_opt ARSampler(obj_jet, (-Inf, Inf))
            @test_opt sample!(sam, n_samples)


            # Test sampling BigFloat
            @test sample!(sam_big, 10_000) isa Vector{BigFloat}
        end
    end


    @testset "Mooncake" begin
        let
            sam = ARSampler(Objective(test_density; adbackend = AutoMooncake()), (-Inf, Inf))
            # Setup samples
            sam_2 = deepcopy(sam)
            Random.seed!(1)
            samples = sample!(sam, n_samples)
            Random.seed!(1)
            samples_2 = sample!(sam_2, n_samples)

            # Tests
            @test samples isa Vector{Float64}
            @test length(samples) == n_samples
            @test samples == samples_2 # Try to catch uninitialized memory

            # JET, errors from within Mooncake
            # @test_opt Objective(test_density; adbackend = AutoMooncake())
            # obj_jet = Objective(test_density; adbackend = AutoMooncake())
            # @test_opt ARSampler(obj_jet, (-Inf, Inf))
            # @test_opt sample!(sam, n_samples)
        end
    end


    @testset "Enzyme" begin
        let
            sam = ARSampler(Objective(test_density; adbackend = AutoEnzyme()), (-Inf, Inf))
            # Setup samples
            sam_2 = deepcopy(sam)
            Random.seed!(1)
            samples = sample!(sam, n_samples)
            Random.seed!(1)
            samples_2 = sample!(sam_2, n_samples)

            # Tests
            @test samples isa Vector{Float64}
            @test length(samples) == n_samples
            @test samples == samples_2 # Try to catch uninitialized memory

            # JET
            @test_opt Objective(test_density; adbackend = AutoEnzyme())
            obj_jet = Objective(test_density; adbackend = AutoEnzyme())
            @test_opt ARSampler(obj_jet, (-Inf, Inf))
            @test_opt sample!(sam, n_samples)
        end
    end
end
