module TestFoldl

using Transducers: Map, ProductRF, TeeRF, __foldl__

using ..Utils: check_rrule

function test_simple()
    check_rrule(__foldl__, +, 0.0, 1:10)
    check_rrule(__foldl__, *, 1.0, 1:5)
    check_rrule(__foldl__, max, 0, [2, 6, 4, 9, 2, 7, 9, 5, 4, 9])
end

function test_tee()
    check_rrule(__foldl__, TeeRF(+, *), (0.0, 1.0), 1:5)
    check_rrule(__foldl__, TeeRF(+, *, max), (0.0, 1.0, 0.0), [2, 9, 6, 4])
    # TODO: Make sure that it can have non-differentiable parts in the accumulator?
    #=
    check_rrule(
        __foldl__,
        TeeRF(+, *, Map(string)'(*), max),
        (0.0, 1.0, "", 0),
        [2, 6, 4, 9, 2, 7, 9, 5, 4, 9],
    )
    =#
end

dup3(x) = (x, x, x)

function test_product()
    check_rrule(__foldl__, Map(dup3)'(ProductRF(+, *, *)), (0.0, 1.0, 0.0), [2, 9, 6, 4])
    # TODO: support zip-of-arrays
    #=
    check_rrule(__foldl__, ProductRF(+, *, *), (0.0, 1.0, 0.0), zip(1:5, 1:5, 'a':'e'))
    =#
end

end  # module
