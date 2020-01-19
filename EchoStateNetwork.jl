module EchoStateNetwork
using SparseArrays
using LinearAlgebra
using CSV


export init_reservoir, init_input_layer, states_matrix, esn_train, esn_predict

function init_reservoir(res_size::Int, 
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
        data::Matrix{Float64}, 
        res_size::Int, 
        train_len::Int,
        alpha::Float64)
    
    states = zeros(Float64, res_size, train_len)
    for i=1:train_len-1
        states[:, i+1] = (1-alpha).*states[:, i] + alpha*tanh.((W*states[:, i])+(W_in*data[:, i]))
    end
    return states
end

function esn_train(beta::Float64, 
        res_size::Int, 
        states::Matrix{Float64},
        data::Matrix{Float64}, 
        nonlin_alg::String)
    
    i_mat = beta.*Matrix(1.0I, res_size, res_size)
    states_new = copy(states)
    if nonlin_alg == nothing
        states_new = states_new
    elseif nonlin_alg == "T1"
        for i=1:size(states_new, 1)
            if mod(i, 2)!=0
                states_new[i, :] = copy(states[i,:].*states[i,:])
            end
         end
    elseif nonlin_alg == "T2"
        for i=2:size(states_new, 1)-1
            if mod(i, 2)!=0
                states_new[i, :] = copy(states[i-1,:].*states[i-2,:])
            end
         end
    elseif nonlin_alg == "T3"
        for i=2:size(states_new, 1)-1
            if mod(i, 2)!=0
                states_new[i, :] = copy(states[i-1,:].*states[i+1,:])
            end
         end
    end
    W_out = (data*transpose(states_new))*inv(states_new*transpose(states_new)+i_mat)

    return W_out
end

function esn_predict(in_size::Int, 
        predict_len::Int, 
        W_in::Matrix{Float64},
        W::Matrix{Float64}, 
        W_out::Matrix{Float64}, 
        states::Matrix{Float64},
        alpha::Float64, 
        nonlin_alg::String)
    
    output = zeros(Float64, in_size, predict_len)
    x = states[:, end]
    for i=1:predict_len
        x_new = copy(x)
        if nonlin_alg == nothing
            x_new = x_new
        elseif nonlin_alg == "T1"
            for j=1:size(x_new, 1)
                if mod(j, 2)!=0
                    x_new[j] = copy(x[j]*x[j])
                end
            end 
        elseif nonlin_alg == "T2"
            for j=2:size(x_new, 1)-1
                if mod(j, 2)!=0
                    x_new[j] = copy(x[j-1]*x[j-2])
                end
            end 
        elseif nonlin_alg == "T3"
            for j=2:size(x_new, 1)-1
                if mod(j, 2)!=0
                    x_new[j] = copy(x[j-1]*x[j+1])
                end
            end 
        end
        out = (W_out*x_new)
        output[:, i] = out
        x = (1-alpha).*x + alpha*tanh.((W*x)+(W_in*out))
    end
    return output
end

end #module

