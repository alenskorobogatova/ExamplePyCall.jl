#https://github.com/aurelio-amerio/docker-julia-pycall
FROM julia:1.7.2-alpine3.15


RUN apk add --update \
    curl \
    && rm -rf /var/cache/apk/*
RUN apk add --update \
    bash \
    && rm -rf /var/cache/apk/*

# #новая попытка
RUN apk --update add \
    bash \
    curl \
    ca-certificates \
    libstdc++ \
    glib \
    && curl "https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub" -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -L "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk" -o glibc.apk \
    && apk add --allow-untrusted glibc.apk \
    && curl -L "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-bin-2.23-r3.apk" -o glibc-bin.apk \
    && apk add --allow-untrusted glibc-bin.apk \
    && curl -L "https://github.com/andyshinn/alpine-pkg-glibc/releases/download/2.25-r0/glibc-i18n-2.25-r0.apk" -o glibc-i18n.apk \
    && apk add --allow-untrusted glibc-i18n.apk \
    && /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc/usr/lib \
    && rm -rf glibc*apk /var/cache/apk/*


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
RUN conda create --name julia python=3.7.3

RUN conda install -n julia conda -y
RUN conda update -n julia --all -y
RUN conda install -y python==3.7.3 
RUN conda install -y numpy
RUN apk add python3-dev
# RUN apk add libpython3-dev

RUN julia -e 'using Pkg; ENV["PYTHON"] = "/root/miniconda3/envs/julia/bin/python"; ENV["CONDA_JL_HOME"] = "/root/miniconda3/envs/julia"; \
   ENV["CONDA_JL_USE_MINIFORGE"] = "1"; Pkg.add("PyCall"); Pkg.add("Conda"); Pkg.build("Conda"); using Conda; Conda.add("numpy"); Pkg.build("PyCall")'

COPY . /root

EXPOSE 8080

RUN julia --project=@. -e 'import Pkg; Pkg.instantiate()'
CMD julia --project=@. -e 'using ExamplePyCall; ExamplePyCall.my_opt()'