FROM jupyter/datascience-notebook:7a0c7325e470

USER root
RUN apt-get update && \
    apt-get install -y gnupg2 \
    build-essential \
    cmake

RUN mkdir ~/.gnupg && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf
RUN apt-key adv --keyserver hkp://pool.sks-keyservers.net:80 --recv 379CE192D401AB61 && \
    echo "deb https://dl.bintray.com/kaitai-io/debian_unstable jessie main" | tee /etc/apt/sources.list.d/kaitai.list && \
    apt-get update --allow-unauthenticated && \
    apt-get install -y kaitai-struct-compiler && \
    apt-get install -y default-jre && \
    apt-get install -y net-tools

# ENV RUSTUP_HOME=/usr/local/rustup \
#     CARGO_HOME=/usr/local/cargo \
#     PATH=/usr/local/cargo/bin:$PATH \
#     RUST_VERSION=1.39.0

# RUN set -eux; \
#     dpkgArch="$(dpkg --print-architecture)"; \
#     case "${dpkgArch##*-}" in \
#         amd64) rustArch='x86_64-unknown-linux-gnu'; rustupSha256='e68f193542c68ce83c449809d2cad262cc2bbb99640eb47c58fc1dc58cc30add' ;; \
#         armhf) rustArch='armv7-unknown-linux-gnueabihf'; rustupSha256='7c1c329a676e50c287d8183b88f30cd6afd0be140826a9fbbc0e3d717fab34d7' ;; \
#         arm64) rustArch='aarch64-unknown-linux-gnu'; rustupSha256='d861cc86594776414de001b96964be645c4bfa27024052704f0976dc3aed1b18' ;; \
#         i386) rustArch='i686-unknown-linux-gnu'; rustupSha256='89f1f797dca2e5c1d75790c3c6b7be0ee473a7f4eca9663e623a41272a358da0' ;; \
#         *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
#     esac; \
#     url="https://static.rust-lang.org/rustup/archive/1.20.2/${rustArch}/rustup-init"; \
#     wget "$url"; \
#     echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
#     chmod +x rustup-init; \
#     ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION; \
#     rm rustup-init; \
#     chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
#     rustup --version; \
#     cargo --version; \
#     rustc --version;


RUN conda install -c damianavila82 rise
RUN conda install -c conda-forge bqplot
RUN conda install -c conda-forge ipywidgets
RUN conda install -c conda-forge jupyter_nbextensions_configurator
RUN conda install -c conda-forge jupyterthemes

USER $NB_UID

# RUN cargo install evcxr_jupyter
# RUN evcxr_jupyter --install

RUN mkdir /tmp/libs
RUN mkdir /tmp/libs/webxi

COPY --chown=$NB_UID ./webxi/ /tmp/libs/webxi
COPY --chown=$NB_UID ./setup.py /tmp/libs
COPY --chown=$NB_UID ./requirements.txt /tmp/libs

RUN fix-permissions /tmp/libs

RUN pip install -r /tmp/libs/requirements.txt
RUN ksc -t python /tmp/libs/webxi/webxi-header.ksy --outdir /tmp/libs/webxi && \
    ksc -t python /tmp/libs/webxi/webxi-stream.ksy --outdir /tmp/libs/webxi && \
    pip install /tmp/libs/