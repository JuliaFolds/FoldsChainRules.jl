module Utils

import ChainRulesTestUtils

check_rrule(args...) = ChainRulesTestUtils.test_rrule(args...; check_inferred = false)

end  # module
