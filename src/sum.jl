# Based on ChainRules.jl

# TODO: Is it fine to re-use the executor for the primal? Should it use more
# "uniform" execution parameter?

function ChainRulesCore.rrule(
    ::typeof(Folds.sum),
    ::typeof(identity),
    xs::AbstractArray,
    ex::Executor,
)
    project = ProjectTo(xs)
    shape = size(xs)
    y = Folds.sum(xs, ex)
    function sum_pullback(dy_raw)
        if dy_raw isa NoTangent
            return (NoTangent(), NoTangent(), NoTangent(), NoTangent())
        end
        dy = unthunk(dy_raw)
        xs_thunk = InplaceableThunk(
            dx -> unsum!(dx, dy, ex),
            @thunk(project(unsum(shape, dy, ex))),
        )
        return (NoTangent(), NoTangent(), xs_thunk, NoTangent())
    end
    return y, sum_pullback
end

function unsum!(dx, dy, ex)
    Folds.foreach(referenceable(dx), ex) do r
        r[] += dy
    end
    dx
end

function unsum(shape, dy, ex)
    xs = Folds.map(_ -> dy, 1:prod(shape; init = 1), ex)
    return reshape(xs, shape)
end

function ChainRulesCore.rrule(
    config::RuleConfig{>:HasReverseMode},
    ::typeof(Folds.sum),
    f,
    xs::AbstractArray,
    ex::Executor,
)
    # TODO: Is it fine to re-use the executor for the primal? Should it use more
    # "uniform" execution parameter?

    # TODO: don't allocate an "intermediate" array for `f(x)`s?
    fx_and_pullbacks = Folds.map(x -> rrule_via_ad(config, f, x), xs, ex)
    y = Folds.sum(first, fx_and_pullbacks, ex)

    pullbacks = Folds.map(last, fx_and_pullbacks, ex)

    project = ProjectTo(xs)

    function sum_pullback(ȳ)
        f̄_and_x̄s = Folds.map(f -> f(ȳ), pullbacks, ex)
        # no point thunking as most of work is in f̄_and_x̄s which we need to compute for both
        f̄ = if fieldcount(typeof(f)) === 0 # Then don't eed to worry about derivative wrt f
            NoTangent()
        else
            Folds.sum(first, f̄_and_x̄s, ex)
        end
        x̄s = Folds.map(unthunk ∘ last, f̄_and_x̄s, ex) # project does not support receiving InplaceableThunks
        return NoTangent(), f̄, project(x̄s), NoTangent()
    end
    return y, sum_pullback
end
