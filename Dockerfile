FROM julia:1.7.2-alpine3.15

WORKDIR  /root/code
ADD . /root/code

RUN julia --project=@. -e 'import Pkg; ENV["PYTHON"]=""; Pkg.build("PyCall")'
RUN julia --project=@. -e 'using ExamplePyCall; ExamplePyCall.my_opt()'