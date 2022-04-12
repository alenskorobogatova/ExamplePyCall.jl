FROM julia:1.7.2-alpine3.15

RUN julia --project=@. -e 'import Pkg; ENV["PYTHON"]=""; Pkg.add("PyCall"); Pkg.build("PyCall")'