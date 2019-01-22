using Mocking
Mocking.enable(force=true)

using Test
using MagneticReadHead


function make_readline_patch(text_queue)
    text_state=nothing
    return @patch function readline(io)
        ret = (text_state==nothing ?
            iterate(text_queue) :
            iterate(text_queue, text_state)
        )
        ret == nothing && error("Out of programmed responses")
        text, text_state = ret
        println(text)
        sleep(0.1)
        return text
    end
end

function make_recording_breadcrumbs_patch()
    record = []
    patch = @patch function breadcrumbs(f, args)
        println("\n", f, typeof.(args)) #simple breadcrumbs for handchecking
        push!(record, (f=f, args=args))
    end
    return patch, record
end

include("demo.jl")
