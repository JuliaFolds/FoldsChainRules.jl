function ChainRulesCore.rrule(
    config::RuleConfig{>:HasReverseMode},
    ::typeof(__foldl__),
    rf,
    init,
    xs::AbstractArray,
)
    rf_fake = ReduceSomePullbackXF(config)'(rf)
    pbtype = Core.Compiler.return_type(
        unreduced_or_throw ∘ foldl_nocomplete,
        Tuple{Typeof(rf_fake),Typeof(init),Typeof(xs)},
    )

    # TODO: Use StructArrays to store `next` pullbacks more efficiently?
    pullbacks = similar(xs, pbtype)
    rf_rr = ArrayPullbackXF(config)'(rf)
    acc, complete_pullback = __foldl__(rf_rr, init, zip(xs, referenceable(pullbacks)))

    function foldl_pullback(ȳ)
        _, r̄f, ācc = complete_pullback(ȳ)
        # TODO: Lazily allocate `x̄s` for
        x̄s = similar(xs, float(eltype(xs)))
        @inline function rf_pb((r̄f, ācc, allnotan), i)
            @inbounds pb = pullbacks[i]
            _, r̄f′, ācc′, x̄ = pb(ācc)
            @inbounds x̄s[i] = x̄
            allnotan &= x̄ isa NoTangent
            return (add!!(r̄f, r̄f′), ācc′, allnotan)
        end
        r̄f, ācc, allnotan = __foldl__(
            Completing(rf_pb),
            (r̄f, ācc, true),
            reverse(eachindex(x̄s, pullbacks)),
        )
        # TODO: Define `reverse(zip(arrays...))` or something equivalent
        # ācc = __foldl__(..., reverse(zip(referenceable(x̄s), pullbacks)))
        return NoTangent(), r̄f, ācc, allnotan ? NoTangent() : x̄s
    end
    return acc, foldl_pullback
end

"""
    ArrayPullbackXF(config::RuleConfig{>:HasReverseMode})

Pullback of reducing function (aka loop body) as a transducer. The "Array"
prefix indicates that the sotrage of the pullbacks are allocated externally as
an array.
"""
struct ArrayPullbackXF{Config} <: Transducer
    config::Config
end

@inline function Transducers.next(rf::R_{ArrayPullbackXF}, acc, (x, r))
    acc′, pb = @inlinecall rrule_via_ad(xform(rf).config, next, inner(rf), acc, x)
    r[] = pb
    return acc′
end

@inline Transducers.complete(rf::R_{ArrayPullbackXF}, acc) =
    rrule_via_ad(xform(rf).config, complete, inner(rf), acc)

#=
"""
    GenericPullbackXF

Generic fallback implementation (but how to construct the output of
`foldl_pullback`?).
"""
struct GenericPullbackXF{Config} <: Transducer
    config::Config
end

@inline function Transducers.next(rf::R_{GenericPullbackXF}, (pullbacks, acc), x)
    acc′, pb = @inlinecall rrule_via_ad(xform(rf).config, next, inner(rf), acc, x)
    push!(pullbacks, pb)
    return pullbacks, acc′
end

@inline Transducers.complete(rf::R_{GenericPullbackXF}, acc) =
    rrule_via_ad(xform(rf).config, complete, inner(rf), acc)
=#

"""
    ReduceSomePullbackXF(config::RuleConfig{>:HasReverseMode})

Transducer that reduces to a pullback of `next` at unspecified point. Used only
for inference.
"""
struct ReduceSomePullbackXF{Config} <: Transducer
    config::Config
end

const _SOME_BOOL = Ref(false)

Transducers.next(rf::R_{ReduceSomePullbackXF}, acc, x) =
    if _SOME_BOOL[]
        _, pb = rrule_via_ad(xform(rf).config, next, inner(rf), acc, x)
        reduced(pb)
    else
        next(inner(rf), acc, x)
    end

Transducers.complete(rf::R_{ReduceSomePullbackXF}, _) = nothing

unreduced_or_throw(x::Reduced) = unreduced(x)
unreduced_or_throw(::Any) = error("unreachable")
