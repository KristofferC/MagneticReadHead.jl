using Revise
using MagneticReadHead
using Test

using MagneticReadHead:
    source_paths,
    containing_methods,
    src_line2ir_statement_ind

@testset "src_line2ir_statement_ind" begin
    ir1line = first(methods(()->1)) |> Base.uncompressed_ast
    @test src_line2ir_statement_ind(ir1line, (@__LINE__)-1) == 1
    @test src_line2ir_statement_ind(ir1line, 1000) == nothing

    ir1line2 = first(methods(()->(x=1;x*x))) |> Base.uncompressed_ast
    @test src_line2ir_statement_ind(ir1line2, (@__LINE__)-1) == 3
    

    ir2line = first(methods(()->(x=1;
                                  x*x))) |> Base.uncompressed_ast
    @test src_line2ir_statement_ind(ir2line, (@__LINE__)-1) == 3
end

@testset "source_paths" begin
    @test source_paths(MagneticReadHead, "utils.jl") |> !isempty
    @test source_paths(MagneticReadHead, "src/utils.jl") == source_paths(MagneticReadHead, "utils.jl")

    @test source_paths(MagneticReadHead, "NOT_REAL") |> isempty
end

@testset "containing_methods" begin
    # BADTEST: This is actually tied to line numbers in the source code
    meth = containing_methods(MagneticReadHead, "src/locate.jl", 56)
    for ln in (55, 56, 57)
        @test meth == containing_methods(MagneticReadHead, "src/locate.jl", ln)
        @test meth == containing_methods(MagneticReadHead, "locate.jl", ln)
        @test meth == containing_methods("locate.jl", ln)
        @test_broken meth ==
            containing_methods(MagneticReadHead, "../src/locate.jl", ln)
        cd(@__DIR__) do
            @test meth == containing_methods(
                MagneticReadHead,
                realpath("../src/locate.jl"),
                ln
            )
        end
    end
end
