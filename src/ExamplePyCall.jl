__precompile__() # this module is safe to precompile
module ExamplePyCall

using PyCall
const scipy_opt = PyNULL()
function __init__()
    copy!(scipy_opt, pyimport_conda("scipy.optimize", "scipy"))
end

function my_opt()
    s = scipy_opt.newton(x -> cos(x) - x, 1)
    println(s)
    return s
end

end