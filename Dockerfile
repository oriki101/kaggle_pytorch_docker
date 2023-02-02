FROM pytorch/pytorch:1.11.0-cuda11.3-cudnn8-runtime

RUN DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone 

RUN apt-get update -y && apt-get install -y \
    libgl1-mesa-glx wget curl git tmux imagemagick htop libsndfile1 nodejs npm nfs-common unzip\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip install wrapt --upgrade --ignore-installed
RUN pip install gym gym-minigrid pyopengl pylint natsort kfp seaborn polars
RUN pip install transformers==4.24.0
RUN pip install librosa
RUN pip install numba==0.48 --ignore-installed
RUN pip install git+https://github.com/h2oai/datatable
RUN pip install fugashi==1.1.0 ipadic==1.0.0


# for jupyter lab tensorboard
RUN npm install n -g \
    && n stable

RUN conda install -c conda-forge jupyterlab
RUN pip install tensorflow==2.4.0 jupyter-tensorboard==0.2.0 tensorflow-estimator==2.4.0 tensorboard==2.4.0
# RUN jupyter labextension install jupyterlab_tensorboard
# Tensorboardのextensionをjupyter3で動かす方法
RUN pip install git+https://github.com/cliffwoolley/jupyter_tensorboard.git
# RUN pip install git+https://github.com/chaoleili/jupyterlab_tensorboard.git
# RUN jupyter tensorboard enable --system
# RUN jupyter lab clean

RUN pip install matplotlib
RUN pip install lightgbm
RUN conda install -y -c conda-forge torchmetrics pytorch-lightning
RUN pip install torchaudio torchsummary


# install code server
RUN conda install jupyter-server-proxy -c conda-forge
# RUN jupyter labextension install @jupyterlab/server-proxy
RUN pip install jupyter-vscode-proxy

# RUN pip install jupyterlab_tabnine
RUN pip install ipywidgets widgetsnbextension
RUN pip install jupyterlab-lsp
RUN pip install 'python-lsp-server[all]'

# install cudf
RUN conda install -y -c rapidsai -c nvidia -c conda-forge cudf=22.12
RUN conda install -y libgcc
RUN conda update -y numpy

# RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN curl -fOL https://github.com/cdr/code-server/releases/download/v3.4.1/code-server_3.4.1_amd64.deb
RUN dpkg -i code-server_3.4.1_amd64.deb
# RUN systemctl --user enable --now code-server

# install jupyter-desktop-server ( noVNC )
# https://github.com/yuvipanda/jupyter-desktop-server
RUN apt-get update -y && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y dbus-x11 \
    xfce4 \
    xfce4-panel \
    xfce4-session \
    xfce4-settings \
    xorg \
    xubuntu-icon-theme \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/yuvipanda/jupyter-desktop-server.git /opt/install
RUN cd /opt/install && \
   conda env update -n base --file environment.yml


# Since uid and gid will change at entrypoint, anything can be used
ARG USER_ID=1000
ARG GROUP_ID=1000
ENV USER_NAME=jovyan
RUN groupadd -g ${GROUP_ID} ${USER_NAME} && \
    useradd -d /home/${USER_NAME} -m -s /bin/bash -u ${USER_ID} -g ${GROUP_ID} ${USER_NAME}
WORKDIR /home/${USER_NAME}

USER ${USER_NAME}
ENV HOME /home/${USER_NAME}

# https://www.hanselman.com/blog/HowToMakeAPrettyPromptInWindowsTerminalWithPowerlineNerdFontsCascadiaCodeWSLAndOhmyposh.aspx
# https://tecadmin.net/install-go-on-ubuntu/
# RUN go get -u github.com/justjanne/powerline-go

USER root
RUN mkdir -p $HOME/.jupyter/lab/user-settings/@jupyterlab/notebook-extension/ \
    && mkdir -p $HOME/.jupyter/lab/user-settings/@jupyterlab/terminal-extension \
    && mkdir -p $HOME/.local/share/code-server/User

# set jupyterlab config  
RUN echo '\n\
{ \n\
    "codeCellConfig": { \n\
        "autoClosingBrackets": true, \n\
        "lineNumbers": true \n\
    } \n\
} \n\
' > $HOME/.jupyter/lab/user-settings/@jupyterlab/notebook-extension/tracker.jupyterlab-settings

RUN echo '\
{ \n\
    "fontFamily": "Cascadia Code PL" \n\
} \n\
' > $HOME/.jupyter/lab/user-settings/@jupyterlab/terminal-extension/plugin.jupyterlab-settings

RUN echo '\
{ \n\
    "editor.fontFamily": "\"Cascadia Code PL\" ", \n\
    "editor.fontLigatures": null, \n\
    "terminal.integrated.shell.linux": "/bin/bash" \n\
} \n\
' > $HOME/.local/share/code-server/User/settings.json


USER root
# COPY entrypoint.sh /usr/local/bin/entrypoint.sh
# RUN chmod +x /usr/local/bin/entrypoint.sh

ENV NB_PREFIX /
ENV SHELL=/bin/bash

# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sh","-c", "jupyter lab --notebook-dir=/home/jovyan --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX}"]
# CMD ["jupyter", "lab", "--no-browser", "--ip=0.0.0.0","--NotebookApp.token=''","--NotebookApp.password=''","--NotebookApp.allow_origin='*'","--allow-root","--port=8888","--NotebookApp.base_url=${NB_PREFIX}"]

## add time news roman
# matplotlibでTimes New Romanが意図せずボールド体になってしまうときの対処法
# https://qiita.com/Miyabi1456/items/ef7a83c239cf0d9478f9
# path: /opt/conda/lib/python3.6/site-packages/matplotlib/font_manger.py
# matplotlibでTimes New Romanを使うためのTips
# http://kenbo.hatenablog.com/entry/2018/11/28/111639

