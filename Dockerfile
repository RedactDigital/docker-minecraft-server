FROM ubuntu:22.04

ENV PAPER_URL=https://api.papermc.io/v2/projects/paper/versions/1.20.1/builds/48/downloads/paper-1.20.1-48.jar
ENV WORKDIR=/minecraft
# Add tmux session name (Used in the scripts we copy later on)
ENV TMUX_SESSION=minecraft

# Install dependencies
RUN apt update && apt upgrade -y && apt install -y --no-install-recommends \
    vim \
    curl \
    wget \
    software-properties-common \
    ca-certificates \
    apt-transport-https \
    gnupg \
    tmux

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

WORKDIR $WORKDIR

# Install velocity
RUN wget $PAPER_URL -O paper.jar

# Copy scripts folder and make them executable
COPY scripts scripts
RUN chmod +x scripts/*

# Add commands to bashrc
RUN echo "alias start='bash $WORKDIR/scripts/start.sh'" >> ~/.bashrc && \
    echo "alias stop='bash $WORKDIR/scripts/stop.sh'" >> ~/.bashrc && \
    echo "alias restart='bash $WORKDIR/scripts/restart.sh'" >> ~/.bashrc && \
    echo "alias debug='bash $WORKDIR/scripts/debug.sh'" >> ~/.bashrc

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
