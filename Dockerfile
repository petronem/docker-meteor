# DOCKER-VERSION 1.8.1
# METEOR-VERSION 1.2.1
FROM debian:jessie

# Create user meteor who will run all entrypoint instructions
RUN useradd meteor -G staff -m -s /bin/bash
WORKDIR /home/meteor

# Install git, curl
# removed installing node from distribution to get better control of installed version
# (curl https://deb.nodesource.com/setup_4.x | bash) && \
#   apt-get install -y nodejs jq && \
# use nvm to install node instead
RUN apt-get update && \
   apt-get install -y git curl && \
   apt-get install -y jq && \
   apt-get clean && \
   rm -Rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \

USER meteor
RUN ( curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash ) && \
   export NVM_DIR="$HOME/.nvm" && \
   [ -s "$NVM_DIR/nvm.sh" ] && \
   . "$NVM_DIR/nvm.sh" && \
   nvm install 4.6.2 && \
   npm install -g semver node-gyp node-pre-gyp

# seeing issues and trying out suggestions from:
# https://github.com/meteor/meteor/issues/7568
# RUN npm install -g semver node-gyp node-pre-gyp

# Install entrypoint
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Add known_hosts file
COPY known_hosts .ssh/known_hosts

RUN chown -R meteor:meteor .ssh /usr/bin/entrypoint.sh

# Allow node to listen to port 80 even when run by non-root user meteor
# don't think we need this because we will use a load balancer in another container
# and will map to the meteor port that's > 1024
# RUN setcap 'cap_net_bind_service=+ep' /usr/bin/nodejs

# not going to expose port 80 because we are using rancher and setting up
# load balancing service in front of containers

# EXPOSE 80

# Execute entrypoint as user meteor
ENTRYPOINT ["su", "-c", "/usr/bin/entrypoint.sh", "meteor"]
CMD []
