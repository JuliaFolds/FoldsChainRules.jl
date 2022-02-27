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
