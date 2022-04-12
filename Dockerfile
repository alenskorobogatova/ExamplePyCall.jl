#https://github.com/aurelio-amerio/docker-julia-pycall
FROM julia:latest

WORKDIR /root
# install miniconda3
RUN curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash Miniconda3-latest-Linux-x86_64.sh -b -p /root/miniconda3
RUN /root/miniconda3/bin/conda init
ENV PATH /root/miniconda3/bin:$PATH

# update conda and create julia environment
RUN conda update -n base conda -y
RUN conda update -n base --all -y
RUN conda install -c conda-forge tmux -y
RUN conda create --name julia python=3.9
RUN conda install -n julia conda -y
RUN conda update -n julia --all -y

RUN julia -e 'using Pkg; ENV["PYTHON"] = ""; ENV["CONDA_JL_HOME"] = "/root/miniconda3/envs/julia"; \
    Pkg.add("PyCall"); Pkg.build("PyCall")'

COPY . /root

EXPOSE 8080

RUN julia --project=@. -e 'import Pkg; Pkg.instantiate()'
CMD julia --project=@. -e 'using ExamplePyCall; ExamplePyCall.my_opt()'