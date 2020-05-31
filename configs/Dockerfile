#================================================================================
# Make conda base environment
#================================================================================
FROM ubuntu:20.04  as conda-base
SHELL ["/bin/bash", "-c"]

ENV TZ Asia/Tokyo
RUN apt-get update \
  && apt-get install -y tzdata \
  && rm -rf /var/lib/apt/lists/* \
  && echo "${TZ}" > /etc/timezone \
  && rm /etc/localtime \
  && ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
  && dpkg-reconfigure -f noninteractive tzdata \
  && apt-get clean

COPY ./files/apt-packagelist.txt .tmp/
RUN apt-get update --fix-missing && \
    apt-get install -y $(grep -vE "^\s*#" .tmp/apt-packagelist.txt  | tr "\n" " ") && \
    apt-get clean

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean

ARG UNAME
ARG GID
ARG UID 
ARG UPASSWD

RUN groupadd jupyterhub -g ${GID}
RUN chgrp -R jupyterhub /opt/ && \
    chmod 770 -R /opt/

RUN echo ${UNAME} ${GID} && \
    useradd -u ${UID} -g jupyterhub -m ${UNAME} --create-home --shel /bin/bash && \
    usermod -aG sudo ${UNAME} && \
    echo "Set disable_coredump false" >> /etc/sudo.conf && \
    echo ${UNAME}:${UPASSWD} | chpasswd
USER ${UNAME}
WORKDIR /home/${UNAME}
#Install Anaconda
ENV PATH /opt/conda/bin:$PATH
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh -O ~/anaconda.sh && \
    bash ~/anaconda.sh -b -p  /opt/conda && \
    rm ~/anaconda.sh && \
    echo "PATH=/opt/conda/bin/:$PATH" >> ~/.bashrc && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

#================================================================================
# Make conda jupyterlab environment
#================================================================================
FROM conda-base as jupyterlab-base
USER root 
WORKDIR ~/

#install jupyter lab extensions
#for  details, see -> https://qiita.com/canonrock16/items/d166c93087a4aafd2db4
#RUN conda install -c conda-forge jupyterlab==2.1.3
RUN pip install jupyterlab==2.1.3
RUN conda install -c conda-forge jupyterhub==1.1.0

#RUN conda install -c conda-forge jupyterhub

COPY ./files/jupyterlab-extensions.txt .tmp/
RUN cat .tmp/jupyterlab-extensions.txt | tr '\n' ' ' > .tmp/tmplist && \
   jupyter labextension install `cat .tmp/tmplist`

#install ML library
COPY ./files/conda-requirements.txt ./files/pip-requirements.txt ./files/anaconda-requirements.txt .tmp/
RUN conda install -c conda-forge --file .tmp/conda-requirements.txt && \
    conda install -c Anaconda --file .tmp/anaconda-requirements.txt && \
    conda clean --all && \
    pip install --no-cache-dir -r .tmp/pip-requirements.txt

ARG JUPYTERHUB_FQDN
WORKDIR /opt/conda
RUN jupyterhub --generate-config
RUN echo "c.Spawner.default_url = '/lab'" >> jupyterhub_config.py
RUN echo "c.ConfigurableHTTPProxy.command = ['configurable-http-proxy', '--redirect-port', '80']" >> jupyterhub_config.py 
RUN echo "c.JupyterHub.ssl_key = '/etc/letsencrypt/live/${JUPYTERHUB_FQDN}/privkey.pem'" >> jupyterhub_config.py
RUN echo "c.JupyterHub.ssl_cert = '/etc/letsencrypt/live/${JUPYTERHUB_FQDN}/fullchain.pem'" >> jupyterhub_config.py
RUN jupyter serverextension enable jupyterlab

#================================================================================
# Set startup configurations
#================================================================================
FROM jupyterlab-base as setup

ARG UNAME
ARG GID
ARG UID 
ARG UPASSWD

USER ${UNAME}
WORKDIR /home/${UNAME}

RUN mkdir ~/.local ~/.ssh  
COPY ./files/register.sh  /home/${UNAME}/

USER root
WORKDIR ~/
RUN sed -i  s/"pam_unix.so obscure sha512"/" pam_unix.so obscure sha512 minlen=8"/ /etc/pam.d/common-password
RUN echo "PATH=/opt/conda/bin/:$PATH" >> ~/.bashrc && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc 
COPY ./files/etc/supervisor/conf.d/* /etc/supervisor/conf.d/
RUN chmod +x /home/${UNAME}/register.sh
RUN  mkdir /var/run/sshd
#================================================================================
# Set startup configurations
#================================================================================
FROM setup
CMD /bin/bash
