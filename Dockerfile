########################################################
#        Renku install section - do not edit           #

FROM renku/renkulab-py:3.10-0.24.0 as builder

# RENKU_VERSION determines the version of the renku CLI
# that will be used in this image. To find the latest version,
# visit https://pypi.org/project/renku/#history.
ARG RENKU_VERSION=2.9.4

FROM renku/renkulab-py:3.10-0.24.0

# Uncomment and adapt if code is to be included in the image
# COPY src /code/src

# Uncomment and adapt if your R or python packages require extra linux (ubuntu) software
# e.g. the following installs apt-utils and vim; each pkg on its own line, all lines
# except for the last end with backslash '\' to continue the RUN line
#

USER root
RUN curl -fsSL https://ollama.com/install.sh | sh
#RUN apt-get install texlive-xetex texlive-fonts-recommended texlive-plain-generic

RUN add-apt-repository universe
RUN apt-get update 
RUN apt-get install texlive-xetex
RUN apt-get install -y pandoc
# RUN curl -L -o install-tl-unx.tar.gz https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
# RUN zcat < install-tl-unx.tar.gz | tar xf -
# RUN cd install-tl-2*
# RUN perl ./install-tl --no-interaction


# ollama
EXPOSE 11434

# RUN apt-get update && \
#    apt-get install -y --no-install-recommends \
#    apt-utils \
#    vim
USER ${NB_USER}

# install the python dependencies
COPY requirements.txt environment.yml /tmp/
RUN mamba env update -q -f /tmp/environment.yml && \
    /opt/conda/bin/pip install -r /tmp/requirements.txt --no-cache-dir && \
    mamba clean -y --all && \
    mamba env export -n "root" && \
    rm -rf ${HOME}/.renku/venv

COPY --from=builder ${HOME}/.renku/venv ${HOME}/.renku/venv
    
# Install renku from pypi or from github if a dev version
RUN if [ -n "$RENKU_VERSION" ] ; then \
        source .renku/venv/bin/activate ; \
        currentversion=$(renku --version) ; \
        if [ "$RENKU_VERSION" != "$currentversion" ] ; then \
            pip uninstall renku -y ; \
            gitversion=$(echo "$RENKU_VERSION" | sed -n "s/^[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\(rc[[:digit:]]\+\)*\(\.dev[[:digit:]]\+\)*\(+g\([a-f0-9]\+\)\)*\(+dirty\)*$/\4/p") ; \
            if [ -n "$gitversion" ] ; then \
                pip install --no-cache-dir --force "git+https://github.com/SwissDataScienceCenter/renku-python.git@$gitversion" ;\
            else \
                pip install --no-cache-dir --force renku==${RENKU_VERSION} ;\
            fi \
        fi \
    fi
#             End Renku install section                #
########################################################

