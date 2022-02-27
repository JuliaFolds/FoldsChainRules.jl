baremodule FoldsChainRules

module Internal

import Folds
using ChainRulesCore: #
    @thunk,
    ChainRulesCore,
    HasReverseMode,
    InplaceableThunk,
    NoTangent,
    ProjectTo,
    RuleConfig,
    add!!,
    rrule_via_ad,
    unthunk
using Core: Typeof
using Referenceables: referenceable
using Transducers: #
    BottomRF,
    Completing,
    Executor,
    R_,
    Reduced,
    Transducer,
    Transducers,
    __foldl__,
    complete,
    foldl_nocomplete,
    inner,
    next,
    reduced,
    unreduced,
    xform

include("utils.jl")
include("foldl.jl")
include("sum.jl")

end  # module Internal

end  # baremodule FoldsChainRules
