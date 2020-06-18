function ESGPtrain(esn::AbstractLeakyESN,
    mean::GaussianProcesses.Mean, 
    kernel::GaussianProcesses.Kernel; 
    lognoise::Float64 = -2.0, 
    optimize::Bool = false,
    optimizer::Optim.AbstractOptimizer = Optim.LBFGS())
    
    states_new = nla(esn.nla_type, esn.states)
    gp = GP(states_new, vec(esn.train_data), mean, kernel, lognoise)
    
    if optimize == true
        optimize!(gp; method=optimizer)
    end
    return gp
end

function ESGPpredict(esn::AbstractLeakyESN,
    predict_len::Int,
    gp::GaussianProcesses.GPE)
    
    output = zeros(Float64, esn.in_size, predict_len)
    sigmas = zeros(Float64, esn.in_size, predict_len)
    x = esn.states[:, end]

    if esn.extended_states == false
        for i=1:predict_len
            x_new = hcat(nla(esn.nla_type, x)...)'
            out, sigma = GaussianProcesses.predict_y(gp, x_new)
            output[:, i] = out
            sigmas[:,i] = sigma
            x = (1-esn.alpha).*x + esn.alpha*esn.activation.((esn.W*x)+(esn.W_in*out))
        end
    else
        for i=1:predict_len
            x_new = hcat(nla(esn.nla_type, x)...)'
            out, sigma = GaussianProcesses.predict_y(gp, x_new)
            output[:, i] = out
            sigmas[:,i] = sigma
            x = vcat((1-esn.alpha).*x[1:esn.res_size] + esn.alpha*esn.activation.((esn.W*x[1:esn.res_size])+(esn.W_in*out)), out) 
        end
    end
    return output, sigmas
end

function ESGPpredict_h_steps(esn::AbstractLeakyESN,
    predict_len::Int,
    h_steps::Int,
    test_data::AbstractArray{Float64},
    gp::GaussianProcesses.GPE)
    
    output = zeros(Float64, esn.in_size, predict_len)
    sigmas = zeros(Float64, esn.in_size, predict_len)
    x = esn.states[:, end]

    if esn.extended_states == false
        for i=1:predict_len
            x_new = hcat(nla(esn.nla_type, x)...)'
            out, sigma = GaussianProcesses.predict_y(gp, x_new)
            output[:, i] = out
            sigmas[:,i] = sigma
            if mod(i, h_steps) == 0
                x = (1-esn.alpha).*x + esn.alpha*esn.activation.((esn.W*x)+(esn.W_in*test_data[:,i]))
            else
                x = (1-esn.alpha).*x + esn.alpha*esn.activation.((esn.W*x)+(esn.W_in*out))
            end
        end
    else
        for i=1:predict_len
            x_new = hcat(nla(esn.nla_type, x)...)'
            out, sigma = GaussianProcesses.predict_y(gp, x_new)
            output[:, i] = out
            sigmas[:,i] = sigma
            if mod(i, h_steps) == 0
                x = vcat((1-esn.alpha).*x[1:esn.res_size] + esn.alpha*esn.activation.((esn.W*x[1:esn.res_size])+
                        (esn.W_in*test_data[:,i])), test_data[:,i])
            else
                x = vcat((1-esn.alpha).*x[1:esn.res_size] + esn.alpha*esn.activation.((esn.W*x[1:esn.res_size])+(esn.W_in*out)), out)
            end
        end
    end
    return output, sigmas
end  
