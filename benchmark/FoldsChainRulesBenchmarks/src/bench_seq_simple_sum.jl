module BenchSeqSimpleSum

import Enzyme
import Zygote
using BenchmarkTools
using FLoops

function sum_loop(xs)
    acc = 0.0
    for x in xs
        acc += x
    end
    return acc
end

function sum_floop(xs)
    @floop begin
        acc = 0.0
        for x in xs
            acc += x
        end
    end
    return acc
end

make_input() = [range(0, 1; length = 1000);]

zygote(sum, xs) = Zygote.gradient(sum, xs)
function enzyme(sum, xs)
    x̄s = similar(xs, float(eltype(xs)))
    Enzyme.autodiff(sum, Enzyme.Duplicated(xs, x̄s)), x̄s
end

function setup()
    suite = BenchmarkGroup()
    for ad in [zygote, enzyme]
        s1 = suite["ad=:$ad"] = BenchmarkGroup()
        for (impl, sum) in [:loop => sum_loop, :floop => sum_floop]
            s1["impl=:$impl"] = @benchmarkable($ad($sum, xs), setup = (xs = make_input()))
        end
    end
    return suite
end

clear() = nothing

end  # module
