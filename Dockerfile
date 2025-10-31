FROM rocker/binder:latest

## Declare build arguments with defaults for your custom user
ARG NB_USER=jovyan

# Switch to root to do the main installation
USER root

# Create user jovyan if not exists
#RUN id -u ${NB_USER} 2>/dev/null || true
#RUN useradd -m -s /bin/bash ${NB_USER}

# Copy your project files to /home/joyvan with ownership
COPY --chown=${NB_USER}:${NB_USER} . /home/${NB_USER}

ENV DEBIAN_FRONTEND=noninteractive

# Move to the /home/${NB_USER} folder where all the local files have been copied
WORKDIR /home/${NB_USER}

# Install apt packages if apt.txt exists
RUN echo "Checking for 'apt.txt'..." && \
    if [ -f "apt.txt" ]; then \
      rm -rf /var/lib/apt/lists && mkdir /var/lib/apt/lists && \
      apt-get update --fix-missing > /dev/null && \
      xargs -a apt.txt apt-get install --yes && \
      apt-get clean > /dev/null && \
      rm -rf /var/lib/apt/lists/* ; \
    fi
# Run R install script if it exists
RUN if [ -f install.R  ]; then R --quiet -f install.R; fi

# Now install BCEA from universe
RUN installRub.r -r noble BCEA@giabaio

# Switch to jovyan user
USER ${NB_USER}

# Copy RStudio prefs to jovyan's config folder
COPY --chown=${NB_USER}:${NB_USER} rstudio-prefs.json /home/${NB_USER}/.config/rstudio/rstudio-prefs.json
