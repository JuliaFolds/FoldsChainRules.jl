macro noop(ex)
    esc(ex)
end

const var"@inlinecall" = if VERSION < v"1.8"
    var"@noop"
else
    var"@inline"
end

@static if VERSION < v"1.8.0-DEV.410"
    using Base: @_inline_meta
else
    const var"@_inline_meta" = Base.var"@inline"
end

"""
    radd!!(a, b) -> c

Recursively add values.

TODO: Check if ChainRules ecosystem already defines it (or something better) somewhere
"""
radd!!(a, b) = add!!(a, b)

radd!!(a::NTuple{N,Any}, b::NTuple{N,Any}) where {N} = map(radd!!, a, b)
radd!!(a::NamedTuple{ns}, b::NamedTuple{ns}) where {ns} =
    NamedTuple{ns}(radd!!(Tuple(a), Tuple(b)))
radd!!(a::NamedTuple, b::NamedTuple) =
    error("cannot merge tangent on incompatible structs:\n", "a = ", a, "\n", "b = ", b)
