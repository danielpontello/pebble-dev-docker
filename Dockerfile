FROM ubuntu:18.04

# Create new user
RUN useradd -ms /bin/bash pebble

# Install prerequisites
RUN apt-get update
RUN apt-get install -y python-pip python2.7-dev libsdl1.2debian libfdt1 \
    libpixman-1-0 npm curl wget git libfreetype6-dev
RUN pip install virtualenv

# Add SDK to the image
WORKDIR /opt/
RUN wget https://github.com/danielpontello/pebble-dev-docker/releases/download/initial-upload/pebble-sdk-4.5-linux64.tar.bz2
RUN tar -xjvf pebble-sdk-4.5-linux64.tar.bz2
RUN rm -rf pebble-sdk-4.5-linux64.tar.bz2

# Install requirements
WORKDIR /opt/pebble-sdk-4.5-linux64
RUN /bin/bash -c " \
    virtualenv --no-site-packages .env && \
    source .env/bin/activate && \
    pip install -r requirements.txt && \
    deactivate"
RUN chown -R pebble:pebble /opt/pebble-sdk-4.5-linux64

# Add to PATH
ENV PATH /opt/pebble-sdk-4.5-linux64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Remove tracking
RUN mkdir -p /home/pebble/.pebble-sdk/
RUN touch /home/pebble/.pebble-sdk/NO_TRACKING

# Change ownership of SDK folder to the pebble user
RUN chown -R pebble:pebble /home/pebble/.pebble-sdk/

# Change to pebble user
USER pebble

# Install SDK Core
RUN yes | pebble sdk install https://github.com/danielpontello/pebble-dev-docker/releases/download/initial-upload/sdk-core-4.3.tar.bz2

# Execute Bash
WORKDIR /home/pebble
CMD /bin/bash