module ReservoirComputing

using SparseArrays
using LinearAlgebra
using MLJLinearModels
using LIBSVM
using GaussianProcesses
using Optim
using Distributions

abstract type AbstractEchoStateNetwork end
abstract type NonLinearAlgorithm end

include("leaky_fixed_rnn.jl")
include("ridge_train.jl")
export ESNtrain, Ridge, Lasso, ElastNet, RobustHuber

include("nla.jl")
export nla, NLADefault, NLAT1, NLAT2, NLAT3

include("esn_input_layers.jl") 
export init_input_layer, init_dense_input_layer, init_sparse_input_layer, min_complex_input
include("esn_reservoirs.jl")
export init_reservoir_givendeg, init_reservoir_givensp, pseudoSVD, DLR, DLRB, SCR

include("echostatenetwork.jl")
export ESN, ESNpredict, ESNpredict_h_steps

include("dafesn.jl")
export dafESN, dafESNpredict, dafESNpredict_h_steps

include("svesm.jl")
export SVESMtrain, SVESM_direct_predict, SVESMpredict, SVESMpredict_h_steps

include("esgp.jl")
export ESGPtrain, ESGPpredict, ESGPpredict_h_steps

include("ECA.jl")
export ECA

end #module
