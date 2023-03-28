module Llama

export run_llama, run_chat
export LlamaContext

import llama_cpp_jll

include("../lib/LibLlama.jl")
# llama_* types
import .LibLlama: llama_context, llama_context_params, llama_token
# llama_* functions
import .LibLlama: llama_context_default_params, llama_init_from_file,
    llama_n_vocab, llama_n_ctx, llama_get_logits, llama_free,
    llama_print_timings, llama_reset_timings, llama_tokenize,
    llama_eval

# executables

function run_llama(; model::AbstractString, prompt::AbstractString="", nthreads::Int=1, args=``)
    cmd = `$(llama_cpp_jll.main()) --model $model --prompt $prompt --threads $nthreads $args`
    return read(cmd, String)
end

function run_chat(; model::AbstractString, prompt::AbstractString="", nthreads::Int=1, args=``)
    cmd = `$(llama_cpp_jll.main()) --model $model --prompt $prompt --threads $nthreads $args -ins`
    run(cmd)
end

# API

mutable struct LlamaContext
    ptr :: Ptr{llama_context}
    model_path :: String
    params :: llama_context_params
    # TODO: n_threads here?

    # TODO
    # - kwargs for params
    function LlamaContext(model_path)
        params = LibLlama.llama_context_default_params()
        ptr = LibLlama.llama_init_from_file(model_path, params)
        if ptr == C_NULL
            error("Error initialising model from file: $model_path")
        end
        ctx = new(ptr, model_path, params)
        finalizer(ctx) do x
            if x.ptr != C_NULL
                LibLlama.llama_free(x.ptr)
            end
        end
    end
end

end # module Llama
