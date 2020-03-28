struct ESN{T<:AbstractFloat}
    res_size::Int
    in_size::Int
    out_size::Int
    train_data::Array{T}
    degree::Int
    sigma::T
    alpha::T
    beta::T
    radius::T
    nonlin_alg::Any
    activation::Any
    W::Matrix{T}
    W_in::Matrix{T}
    states::Matrix{T}

    function ESN(approx_res_size::Int,
            train_data::Array{T},
            degree::Int,
            radius::T,
            activation::Function = tanh,
            sigma::T = 0.1,
            alpha::T = 1.0,
            beta::T = 0.0,
            nonlin_alg::Any = NonLinAlgDefault) where T<:AbstractFloat

        in_size = size(train_data)[1]
        out_size = size(train_data)[1] #needs to be different?
        res_size = Int(floor(approx_res_size/in_size)*in_size)
        W = init_reservoir(res_size, in_size, radius, degree)
        W_in = init_input_layer(res_size, in_size, sigma)
        states = states_matrix(W, W_in, train_data, alpha, activation)

        return new{T}(res_size, in_size, out_size, train_data,
        degree, sigma, alpha, beta, radius, nonlin_alg, activation, W, W_in, states)
    end
end


function init_reservoir(res_size::Int,
        in_size::Int,
        radius::Float64,
        degree::Int)

    sparsity = degree/res_size
    W = Matrix(sprand(Float64, res_size, res_size, sparsity))
    W = 2.0 .*(W.-0.5)
    replace!(W, -1.0=>0.0)
    rho_w = maximum(abs.(eigvals(W)))
    W .*= radius/rho_w
    return W
end

function init_input_layer(res_size::Int,
        in_size::Int,
        sigma::Float64)

    W_in = zeros(Float64, res_size, in_size)
    q = Int(res_size/in_size)
    for i=1:in_size
        W_in[(i-1)*q+1 : (i)*q, i] = (2*sigma).*(rand(Float64, 1, q).-0.5)
    end
    return W_in
end

function states_matrix(W::Matrix{Float64},
        W_in::Matrix{Float64},
        train_data::Array{Float64},
        alpha::Float64,
        activation::Function)

    train_len = size(train_data)[2]
    res_size = size(W)[1]
    states = zeros(Float64, res_size, train_len)
    for i=1:train_len-1
        states[:, i+1] = (1-alpha).*states[:, i] + alpha*activation.((W*states[:, i])+(W_in*train_data[:, i]))
    end
    return states
end

function ESNtrain(esn::ESN)

    i_mat = esn.beta.*Matrix(1.0I, esn.res_size, esn.res_size)
    states_new = esn.nonlin_alg(esn.states)
    W_out = (esn.train_data*transpose(states_new))*inv(states_new*transpose(states_new)+i_mat)

    return W_out
end

function ESNpredict(esn::ESN,
    predict_len::Int,
    W_out::Matrix{Float64})

    output = zeros(Float64, esn.in_size, predict_len)
    x = esn.states[:, end]
    for i=1:predict_len
        x_new = esn.nonlin_alg(x)
        out = (W_out*x_new)
        output[:, i] = out
        x = (1-esn.alpha).*x + esn.alpha*esn.activation.((esn.W*x)+(esn.W_in*out))
    end
    return output
end


#needs better implementation
function ESNsingle_predict(esn::ESN,
    predict_len::Int,
    partial::Array{Float64},
    test_data::Matrix{Float64},
    W_out::Matrix{Float64})

    output = zeros(Float64, esn.in_size, predict_len)
    out_new = zeros(Float64, esn.out_size)
    x = esn.states[:, end]
    for i=1:predict_len
        x_new = esn.nonlin_alg(x)
        output[:, i] = out_new        
        x = (1-esn.alpha).*x + esn.alpha*esn.activation.((esn.W*x)+(esn.W_in*out_new))
    end
    return output
end

