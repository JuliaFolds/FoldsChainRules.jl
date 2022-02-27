module TestSum

using Test
using Folds

using ..Utils: check_rrule

function test_rrule()
    @testset for ex in [SequentialEx(), ThreadedEx()], f in [identity, abs]
        check_rrule(Folds.sum, f, 1:10, ex)
    end
end

end  # module
