FROM ubuntu:22.04

ENV USER=minecraft
ENV UID=1000
ENV GID=1000
ENV WORKDIR=/minecraft
# Vars used in scripts and entrypoint
ENV TMUX_SESSION=minecraft
ENV PROJECT=paper

# Create user and group
RUN groupadd --gid ${GID} ${USER} && \
    useradd --create-home --shell /bin/bash --uid ${UID} --gid ${GID} ${USER} && \
    usermod -aG sudo ${USER}

# Install dependencies
RUN apt update && apt upgrade -y && apt install -y --no-install-recommends \
    vim \
    curl \
    wget \
    software-properties-common \
    ca-certificates \
    apt-transport-https \
    gnupg \
    tmux \
    jq

# Import the Amazon Corretto public key and repository
RUN curl https://apt.corretto.aws/corretto.key | apt-key add - && \
    add-apt-repository 'deb https://apt.corretto.aws stable main'

# Install Java
RUN apt update && apt install -y --no-install-recommends \
    java-17-amazon-corretto-jdk \
    libxi6 \
    libxtst6 \
    libxrender1

# Install Cleanup
RUN apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

USER ${USER}
WORKDIR $WORKDIR

# Copy scripts folder and make them executable
COPY --chown=${USER}:${USER} scripts scripts
RUN chmod +x scripts/*

# Add commands to bashrc
RUN echo "alias start='bash $WORKDIR/scripts/start.sh'" >> ~/.bashrc && \
    echo "alias stop='bash $WORKDIR/scripts/stop.sh'" >> ~/.bashrc && \
    echo "alias restart='bash $WORKDIR/scripts/restart.sh'" >> ~/.bashrc && \
    echo "alias debug='bash $WORKDIR/scripts/debug.sh'" >> ~/.bashrc

# Copy entrypoint
COPY --chown=${USER}:${USER} entrypoint.sh /home/${USER}/entrypoint.sh
RUN chmod +x /home/${USER}/entrypoint.sh

ENTRYPOINT ["sh", "-c", "/home/$USER/entrypoint.sh"]
