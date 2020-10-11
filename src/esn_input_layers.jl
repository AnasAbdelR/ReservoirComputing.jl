

"""
    init_input_layer(res_size::Int, in_size::Int, sigma::Float64)

Return a weighted input layer matrix, with random non-zero elements drawn from \$ [-\\text{sigma}, \\text{sigma}] \$, as described in [1].

[1] Lu, Zhixin, et al. "Reservoir observers: Model-free inference of unmeasured variables in chaotic systems." Chaos: An Interdisciplinary Journal of Nonlinear Science 27.4 (2017): 041102.
"""
function init_input_layer(res_size::Int,
        in_size::Int,
        sigma::Float64)

    W_in = zeros(Float64, res_size, in_size)
    q = floor(Int, res_size/in_size) #need to fix the reservoir input size. Check the constructor
    for i=1:in_size
        W_in[(i-1)*q+1 : (i)*q, i] = (2*sigma).*(rand(Float64, 1, q).-0.5)
    end
    return W_in

end

"""
    init_dense_input_layer(res_size::Int, in_size::Int, sigma::Float64)

Return a fully connected input layer matrix, with random non-zero elements drawn from \$ [-sigma, sigma] \$.
"""
function init_dense_input_layer(res_size::Int,
        in_size::Int,
        sigma::Float64)

    W_in = rand(Float64, res_size, in_size)
    W_in = 2.0 .*(W_in.-0.5)
    W_in = sigma .*W_in
    return W_in
end

"""
    init_sparse_input_layer(res_size::Int, in_size::Int, sigma::Float64, sparsity::Float64)

Return a sparsely connected input layer matrix, with random non-zero elements drawn from \$ [-sigma, sigma] \$ and given sparsity.
"""
function init_sparse_input_layer(res_size::Int,
        in_size::Int,
        sigma::Float64,
        sparsity::Float64)

    W_in = Matrix(sprand(Float64, res_size, in_size, sparsity))
    W_in = 2.0 .*(W_in.-0.5)
    replace!(W_in, -1.0=>0.0)
    W_in = sigma .*W_in
    return W_in
end

#from "minimum complexity echo state network" Rodan
"""
    min_complex_input(res_size::Int, in_size::Int, weight::Float64)

Return a fully connected input layer matrix with the same weights and sign drawn from a Bernoulli distribution, as described in [1].

[1] Rodan, Ali, and Peter Tino. "Minimum complexity echo state network." IEEE transactions on neural networks 22.1 (2010): 131-144.
"""
function min_complex_input(res_size::Int,
        in_size::Int,
        weight::Float64)

    W_in = Array{Float64}(undef, res_size, in_size)
    for i=1:res_size
        for j=1:in_size
            if rand(Bernoulli()) == true
                W_in[i, j] = weight
            else
                W_in[i, j] = -weight
            end
        end
    end
    return W_in
end

#from "minimum complexity echo state network" Rodan
#and "simple deterministically constructed cycle reservoirs with regular jumps" by Rodan and Tino

"""
    irrational_sign_input(res_size::Int, in_size::Int , weight::Float64 [, start::Int, irrational::Irrational])

Return a fully connected input layer matrix with the same weights and sign decided by the values of an irrational number, as described in [1] and [2].

[1] Rodan, Ali, and Peter Tino. "Minimum complexity echo state network." IEEE transactions on neural networks 22.1 (2010): 131-144.
[2] Rodan, Ali, and Peter Tiňo. "Simple deterministically constructed cycle reservoirs with regular jumps." Neural computation 24.7 (2012): 1822-1852.
"""
function irrational_sign_input(res_size::Int,
        in_size::Int,
        weight::Float64;
        start::Int = 1,
        irrational::Irrational = pi)

    setprecision(BigFloat, Int(ceil(log2(10)*(res_size*in_size+start+1))))
    ir_string = string(BigFloat(irrational)) |> collect
    deleteat!(ir_string, findall(x->x=='.', ir_string))
    ir_array = Array{Int}(undef, length(ir_string))
    W_in = Array{Float64}(undef, res_size, in_size)

    for i =1:length(ir_string)
        ir_array[i] = parse(Int, ir_string[i])
    end

    counter = start

    for i=1:res_size
        for j=1:in_size
            if ir_array[counter] < 5
                W_in[i, j] = -weight
            else
                W_in[i, j] = weight
            end
            counter += 1
        end
    end
    return W_in
end
