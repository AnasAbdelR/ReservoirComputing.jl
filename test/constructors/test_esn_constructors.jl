using ReservoirComputing

#model parameters
approx_res_size = 30
radius = 1.2
activation = tanh
degree = 6
sigma = 0.1
beta = 0.0
alpha = 1.0
nla_type = NLADefault()
in_size = 3
out_size = 3
W_in = ReservoirComputing.init_input_layer(approx_res_size, in_size, sigma)
W = ReservoirComputing.init_reservoir_givendeg(approx_res_size, radius, degree)
extended_states = false
h_steps = 2


train_len = 50
predict_len = 12
data = ones(Float64, in_size, 100)
train = data[:, 1:1+train_len-1]
test = data[:, train_len:train_len+predict_len-1]

#constructor 1
esn = ESN(approx_res_size,
    train,
    degree,
    radius,
    activation,
    sigma,
    alpha,
    nla_type,
    extended_states)

#test constructor
@test isequal(Integer(floor(approx_res_size/in_size)*in_size), esn.res_size)
@test isequal(train, esn.train_data)
@test isequal(alpha, esn.alpha)
@test isequal(activation, esn.activation)
@test isequal(nla_type, esn.nla_type)
@test size(esn.W) == (esn.res_size, esn.res_size)
@test size(esn.W_in) == (esn.res_size, esn.in_size)
@test size(esn.states) == (esn.res_size, train_len)

#test train
W_out = ESNtrain(esn, beta)
@test size(W_out) == (out_size, esn.res_size)
#test predict
output = ESNpredict(esn, predict_len, W_out)
@test size(output) == (out_size, predict_len)
#test h steps predict
output = ESNpredict_h_steps(esn, predict_len, h_steps, test, W_out)
@test size(output) == (out_size, predict_len)


#constructor 2
esn = ESN(W,
    train,
    activation,
    sigma,
    alpha,
    nla_type,
    extended_states)

#test constructor
@test isequal(approx_res_size, esn.res_size)
@test isequal(train, esn.train_data)
@test isequal(alpha, esn.alpha)
@test isequal(activation, esn.activation)
@test isequal(nla_type, esn.nla_type)
@test size(esn.W) == (esn.res_size, esn.res_size)
@test size(esn.W_in) == (esn.res_size, esn.in_size)
@test size(esn.states) == (esn.res_size, train_len)

#test train
W_out = ESNtrain(esn, beta)
@test size(W_out) == (out_size, esn.res_size)
#test predict
output = ESNpredict(esn, predict_len, W_out)
@test size(output) == (out_size, predict_len)

#constructor 3
esn = ESN(approx_res_size,
    train,
    degree,
    radius,
    W_in,
    activation,
    alpha,
    nla_type,
    extended_states)

#test constructor
@test isequal(Integer(floor(approx_res_size/in_size)*in_size), esn.res_size)
@test isequal(train, esn.train_data)
@test isequal(alpha, esn.alpha)
@test isequal(activation, esn.activation)
@test isequal(nla_type, esn.nla_type)
@test size(esn.W) == (esn.res_size, esn.res_size)
@test size(esn.W_in) == (esn.res_size, esn.in_size)
@test size(esn.states) == (esn.res_size, train_len)

#test train
W_out = ESNtrain(esn, beta)
@test size(W_out) == (out_size, esn.res_size)
#test predict
output = ESNpredict(esn, predict_len, W_out)
@test size(output) == (out_size, predict_len)

#constructor 4
esn = ESN(W,
    train,
    W_in,
    activation,
    alpha,
    nla_type,
    extended_states)

#test constructor
@test isequal(approx_res_size, esn.res_size)
@test isequal(train, esn.train_data)
@test isequal(alpha, esn.alpha)
@test isequal(activation, esn.activation)
@test isequal(nla_type, esn.nla_type)
@test size(esn.W) == (esn.res_size, esn.res_size)
@test size(esn.W_in) == (esn.res_size, esn.in_size)
@test size(esn.states) == (esn.res_size, train_len)

#test train
W_out = ESNtrain(esn, beta)
@test size(W_out) == (out_size, esn.res_size)
#test predict
output = ESNpredict(esn, predict_len, W_out)
@test size(output) == (out_size, predict_len)
