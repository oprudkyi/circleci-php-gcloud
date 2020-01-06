FROM circleci/php:7.3.13-zts-buster-node AS build

#install gcloud sdk with all stuff
RUN export CLOUDSDK_CORE_DISABLE_PROMPTS=1 && \
    curl https://sdk.cloud.google.com | bash

#automatic include of google cloud sdk
RUN echo "source /home/circleci/google-cloud-sdk/completion.bash.inc" >> /home/circleci/.bashrc && \
    echo "source /home/circleci/google-cloud-sdk/path.bash.inc" >> /home/circleci/.bashrc

#install custom gcloud sdk components
RUN bash -c "source /home/circleci/google-cloud-sdk/path.bash.inc && gcloud --quiet components install kubectl beta docker-credential-gcr"

RUN sudo apt-get update -y && \
    sudo apt-get install -y \
        libzip4 \
        libpng-dev \
        libmcrypt-dev \
        libxml2-dev \
        libmagickwand-6.q16-6 \
        libmagickwand-dev \
        libmcrypt4 \
        gettext-base \
        vim

#install php modules
RUN sudo docker-php-ext-install gd bcmath pdo pdo_mysql soap exif zip intl

RUN sudo pecl channel-update pecl.php.net

RUN sudo bash -c "yes '' | sudo pecl install mcrypt || true"
RUN sudo bash -c "yes '' | sudo pecl install imagick || true"
RUN sudo bash -c "yes '' | sudo pecl install grpc || true"
RUN sudo bash -c "yes '' | sudo pecl install protobuf || true"

#enable pecl extensions
RUN sudo docker-php-ext-enable imagick grpc protobuf mcrypt

RUN sudo apt-get remove -y '.*-dev$' && \
    sudo apt-get remove -y '.*-headers$' && \
    sudo apt-get remove -y '.*-devel$' && \
    sudo apt-get clean && \
    sudo apt autoremove && \
    sudo rm -rf /tmp/* /var/tmp/*

# This results in a single layer image
FROM scratch
COPY --from=build / /
