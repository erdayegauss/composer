# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Fixed to last known good level at deprecation; later versions fail build due to Alpine upgrade
FROM node:8.15.1-alpine

# Reset npm logging to default level.
ENV NPM_CONFIG_LOGLEVEL warn

# Install the latest version by default.
ARG VERSION=0.19.13

# Need to install extra dependencies for native modules.
RUN deluser --remove-home node && \
    addgroup -g 1000 composer && \
    adduser -u 1000 -G composer -s /bin/sh -D composer && \
    apk add --no-cache make gcc g++ python git libc6-compat && \
    su -c "npm config set prefix '/home/composer/.npm-global'" - composer && \
    su -c "npm install --production -g pm2 composer-cli@${VERSION}  composer-rest-server@${VERSION} generator-hyperledger-composer@${VERSION}  composer-playground@${VERSION} composer-wallet-redis composer-wallet-cloudant composer-wallet-ibmcos" - composer && \
    su -c "npm cache clean --force" - composer && \
    rm -rf /home/composer/.config /home/composer/.node-gyp /home/composer/.npm && \
    apk del make gcc g++ python git

# Run as the composer user ID.
USER composer

# Add global composer modules to the path.
ENV PATH /home/composer/.npm-global/bin:$PATH

# Run in the composer users home directory.
WORKDIR /home/composer

COPY bond-network.bna  bond-network.bna
COPY connection_admin.json  connection_admin.json
COPY composer composer
COPY key key
COPY cert cert


# Run supervisor to start the application.
CMD [ "sh", "composer" ]

# Expose port 8080.
EXPOSE 5555
