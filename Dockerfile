FROM circleci/php:7.1.25-stretch-browsers

ARG NODE_VERSION
ENV NODE_VERSION ${NODE_VERSION:-10}

#install gcloud sdk with all stuff
RUN export CLOUDSDK_CORE_DISABLE_PROMPTS=1 && \
    curl https://sdk.cloud.google.com | bash

#automatic include of google cloud sdk
RUN echo "source /home/circleci/google-cloud-sdk/completion.bash.inc" >> /home/circleci/.bashrc && \
    echo "source /home/circleci/google-cloud-sdk/path.bash.inc" >> /home/circleci/.bashrc

#install custom gcloud sdk components
RUN bash -c "source /home/circleci/google-cloud-sdk/path.bash.inc && gcloud --quiet components install kubectl beta docker-credential-gcr"

#manually bump kubectl to 1.13
RUN sudo wget https://storage.googleapis.com/kubernetes-release/release/v1.13.1/bin/linux/amd64/kubectl && \
    sudo mv -f ./kubectl /home/circleci/google-cloud-sdk/bin/kubectl && \
    sudo chmod +x /home/circleci/google-cloud-sdk/bin/kubectl

#install php modules
RUN sudo apt-get update -y && sudo apt-get install -y libpng-dev libmcrypt-dev libxml2-dev libmagickwand-dev && \
    sudo docker-php-ext-install gd bcmath mcrypt pdo pdo_mysql soap exif zip

RUN sudo pecl channel-update pecl.php.net

RUN sudo bash -c "yes '' | sudo pecl install imagick || true"
RUN sudo bash -c "yes '' | sudo pecl install grpc || true"
RUN sudo bash -c "yes '' | sudo pecl install protobuf || true"

#enable pecl extensions
RUN sudo docker-php-ext-enable imagick grpc protobuf

#install node
RUN rm -rf ~/.nvm && \
    git clone https://github.com/creationix/nvm.git ~/.nvm && \
    (cd ~/.nvm && git checkout `git describe --abbrev=0 --tags`) && \
    bash -c "source ~/.nvm/nvm.sh && nvm install $NODE_VERSION"

#automatic include of npm
RUN echo "source /home/circleci/.nvm/nvm.sh" >> /home/circleci/.bashrc

#install gulp
RUN bash -c "source ~/.nvm/nvm.sh && npm install --global gulp-cli"

#install bower
RUN bash -c "source ~/.nvm/nvm.sh && npm install --global bower"

#install yarn
RUN bash -c "source ~/.nvm/nvm.sh && npm install --global yarn"

#minimize build
RUN sudo apt-get remove -y libpng-dev libmcrypt-dev && sudo apt-get clean && sudo apt autoremove && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*