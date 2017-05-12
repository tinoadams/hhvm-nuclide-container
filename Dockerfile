FROM ubuntu:xenial

RUN apt-get update

RUN apt-get install -y git
RUN apt-get install -y curl

# install nodejs
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get install -y nodejs

# install watchman
RUN git clone https://github.com/facebook/watchman.git \
    && cd watchman/ \
    && git checkout v4.7.0 \
    && apt-get install -y autoconf automake build-essential python-dev \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && cd .. && rm -rf watchman \
    && apt-get remove --purge -y autoconf automake build-essential python-dev

# install nuclide server
RUN npm install -g nuclide

# install hhvm
RUN apt-get install -y software-properties-common \
    && apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449 \
    && add-apt-repository "deb http://dl.hhvm.com/ubuntu xenial main" \
    && apt-get update \
    && apt-get install -y hhvm

RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb \
    && dpkg -i dumb-init_*.deb \
    && rm -f dumb-init_*.deb
RUN apt-get install -y supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENTRYPOINT ["/usr/bin/dumb-init", "--", "supervisord", "-n"]

# configure hhvm
COPY php.ini /etc/hhvm/php.ini
COPY server.ini /etc/hhvm/server.ini