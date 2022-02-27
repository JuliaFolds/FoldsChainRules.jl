using Pkg

Pkg.develop([
    PackageSpec(
        name = "FoldsChainRules",
        path = dirname(@__DIR__),
        # url = ...,
    ),
    PackageSpec(
        name = "FoldsChainRulesBenchmarks",
        path = dirname(@__DIR__),
        # url = ...,
        subdir = "benchmark/FoldsChainRulesBenchmarks",
    ),
])

Pkg.instantiate()
