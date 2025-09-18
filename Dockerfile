FROM rocker/binder:latest

## Declare build arguments with defaults for your custom user
ARG NB_USER=joyvan
##### ARG git_personal_token

USER root

# Create user bmhe if not exists
RUN id -u ${NB_USER} 2>/dev/null || \
    useradd -m -s /bin/bash ${NB_USER}

# Copy your project files to /home/bmhe with ownership
COPY --chown=${NB_USER}:${NB_USER} . /home/${NB_USER}

ENV DEBIAN_FRONTEND=noninteractive

# Install apt packages if apt.txt exists
RUN echo "Checking for 'apt.txt'..." \
        ; if test -f "apt.txt" ; then \
        rm -rf /var/lib/apt/lists && mkdir /var/lib/apt/lists && \ 
        apt-get update --fix-missing > /dev/null && \
        xargs -a apt.txt apt-get install --yes && \
        apt-get clean > /dev/null && \
        rm -rf /var/lib/apt/lists/* \
        ; fi
## Run an install.R script, if it exists.
RUN if [ -f install.R ]; then R --quiet -f install.R; fi
USER ${NB_USER}

