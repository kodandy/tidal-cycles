FROM debian:jessie
MAINTAINER Mauro <mauro@sdf.org>

###
#
# Define ENV_VARS
#
###
ENV LANG C.UTF-8
ENV USER root

ENV HOME /home/tidal
ENV PATH $PATH:$HOME/bin

ENV DEBIAN_FRONTEND noninteractive

####
#
# Add backports.
# `ghc` is kinda old in Jessie, luckily someone backported it.
#
##
COPY ["config/etc/apt/sources.list.d/backports.list", "/etc/apt/sources.list.d/backports.list"]

###
#
# Install dependencies &&
# Create home and user dirs
#
###
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -yq \
    emacs24-nox haskell-mode \
    zlib1g-dev liblo7 libasound2-dev \
    cabal-install wget unzip \
    ca-certificates \
    --no-install-recommends \
    && apt-get install -yt jessie-backports ghc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p $HOME \
    && mkdir -p $HOME/livecode \
    && mkdir -p $HOME/.emacs.d/themes \
    && mkdir -p $HOME/.emacs.d/lisp \
    && wget https://github.com/lvm/tidal-drum-patterns/archive/master.zip -O $HOME/tidal-drum-patterns.zip \
    && wget https://raw.githubusercontent.com/lvm/monochrome-theme.el/master/monochrome-transparent-theme.el -O $HOME/.emacs.d/themes/monochrome-transparent-theme.el \
    && wget https://www.emacswiki.org/emacs/download/centered-cursor-mode.el -O $HOME/.emacs.d/lisp/centered-cursor-mode.el

###
#
# COPY default configs
#
###
COPY ["config/.bashrc", "$HOME/.bashrc"]
COPY ["config/.motd", "$HOME/.motd"]
COPY ["config/.emacs", "$HOME/.emacs"]
COPY ["config/tidal.el", "$HOME/.emacs.d/lisp/tidal.el"]
COPY ["tidal/init.tidal", "$HOME/livecode/init.tidal"]
COPY ["tidal/helpers.tidal", "$HOME/livecode/helpers.tidal"]

###
#
# Install Tidal && Fix perms
#
###


RUN cabal update \
    && cabal install 'tidal==0.9' \
    && unzip $HOME/tidal-drum-patterns.zip -d $HOME \
    && cd $HOME/tidal-drum-patterns-master \
    && cabal configure && cabal build && cabal install \
    && cd $HOME \
    && rm -fr $HOME/tidal-drum-patterns-master $HOME/tidal-drum-patterns.zip \
    && rm -fr $HOME/Tidal-0.9-dev $HOME/tidal-0.9.zip \
    && chown -Rh $USER:$USER -- $HOME


###
#
# Init
#
###
USER $USER
WORKDIR $HOME
