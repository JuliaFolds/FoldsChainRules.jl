baremodule FoldsChainRules

module Internal

# import Folds
using ChainRulesCore: #
    ChainRulesCore,
    HasReverseMode,
    NoTangent,
    RuleConfig,
    add!!,
    rrule_via_ad
using Core: Typeof
using Referenceables: referenceable
using Transducers: #
    BottomRF,
    Completing,
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
# include("reduce.jl")

end  # module Internal

end  # baremodule FoldsChainRules
