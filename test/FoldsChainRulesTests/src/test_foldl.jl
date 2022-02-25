module TestFoldl

import ChainRulesTestUtils
import FoldsChainRules
using Test
using Transducers: __foldl__

check_rrule(args...) = ChainRulesTestUtils.test_rrule(args...; check_inferred = false)

function test_sum()
    check_rrule(__foldl__, +, 0.0, 1:10)
    check_rrule(__foldl__, *, 1.0, 1:5)
    check_rrule(__foldl__, max, 0, [2, 6, 4, 9, 2, 7, 9, 5, 4, 9])
end

end  # module
