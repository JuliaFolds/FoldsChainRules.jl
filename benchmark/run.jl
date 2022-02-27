@info "Loading packages"
import FoldsChainRules
import FoldsChainRulesBenchmarks

@info "Start warmup"
run(FoldsChainRulesBenchmarks.setup_smoke(); verbose = true)

@info "Start benchmarks"
SUITE = FoldsChainRulesBenchmarks.setup()
RESULTS = run(SUITE; verbose = true)

if abspath(PROGRAM_FILE) == @__FILE__
    display(RESULTS)
    println()
end

RESULTS
