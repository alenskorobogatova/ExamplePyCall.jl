# Note: Ubuntu is being used due to familiarity only
#FROM ubuntu:18.04

#COPY . /app
#WORKDIR /app

#USER root

## Julia install dependencies and Python development
#RUN apt-get update && apt-get install -yq --no-install-recommends \
#    wget \
#    ca-certificates \
#    python3 \
#    python3-dev \
#    python3-pip


# Julia dependencies
# Install Julia packages in /opt/julia instead of $HOME
#ENV JULIA_DEPOT_PATH=/opt/julia
#ENV JULIA_PKGDIR=/opt/julia
#ENV JULIA_VERSION=1.0.2

#RUN mkdir /opt/julia-${JULIA_VERSION} && \
#    cd /tmp && \
#    wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
#    echo "e0e93949753cc4ac46d5f27d7ae213488b3fef5f8e766794df0058e1b3d2f142 *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - && \
#    tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
#    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
#RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

# Install PyJulia requirement PyCall
#RUN julia -e 'import Pkg; Pkg.update()' && \
#    julia -e 'import Pkg; Pkg.add("PyCall")'

#RUN julia --project=@. -e 'import Pkg; ENV["PYTHON"]=""; Pkg.build("PyCall")'
#CMD julia --project=@. -e 'using ExamplePyCall; ExamplePyCall.my_opt()'

#RUN julia --project=@. -e 'import Pkg; ENV["PYTHON"]=""; Pkg.build("PyCall")'
#RUN julia --project=@. -e 'using ExamplePyCall; ExamplePyCall.my_opt()'

# Install PyJulia
#RUN python3 -m pip install julia && \
#    python-jl --version

# Use the command python-jl, because finding the julia install is hard
#RUN julia --project=@. -e 'import Pkg; ENV["PYTHON"]=""; Pkg.build("PyCall")'
#RUN julia --project=@. -e 'using ExamplePyCall; ExamplePyCall.my_opt()'

#CMD ["python-jl", "app.py"]



#https://github.com/aurelio-amerio/docker-julia-pycall
FROM julia:latest

LABEL maintainer="Alena S" 
ENV USERNAME ais2
# RUN userdel nobody 

# add a user USERNAME with password USERNAME
RUN useradd -ms /bin/bash  -p $(echo ${USERNAME} | openssl passwd -1 -stdin) ${USERNAME}
USER ${USERNAME}

WORKDIR /tmp
# install miniconda3
RUN curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash Miniconda3-latest-Linux-x86_64.sh -b -p /home/${USERNAME}/miniconda3
RUN /home/${USERNAME}/miniconda3/bin/conda init
ENV PATH /home/${USERNAME}/miniconda3/bin:$PATH

# update conda and create julia environment
RUN conda update -n base conda -y
RUN conda update -n base --all -y
RUN conda install -c conda-forge tmux -y
RUN conda create --name julia python=3.9
RUN conda install -n julia conda -y
RUN conda update -n julia --all -y

COPY install-pycall-docker.jl /tmp
# install pycall
RUN julia install-pycall-docker.jl
# clear tmp folder

USER root
RUN rm -rf /tmp/*

USER ${USERNAME}

WORKDIR /home/${USERNAME}
COPY . /home/${USERNAME}

RUN julia --project=@. -e 'import Pkg; Pkg.instantiate()'
CMD julia --project=@. -e 'using ExamplePyCall; ExamplePyCall.my_opt()'