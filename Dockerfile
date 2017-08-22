FROM circleci/php:7.1.8-browsers

#install gcloud sdk with all stuff
RUN export CLOUDSDK_CORE_DISABLE_PROMPTS=1 && \
    curl https://sdk.cloud.google.com | bash

#automatic include for google cloud sdk
RUN echo "source /home/circleci/google-cloud-sdk/completion.bash.inc" >> ~/.bashrc && \
    echo "source /home/circleci/google-cloud-sdk/path.bash.inc" >> ~/.bashrc

#install custom gcloud sdk components
RUN bash -c "source /home/circleci/google-cloud-sdk/path.bash.inc && gcloud --quiet components install kubectl beta docker-credential-gcr"

#install php modules
RUN sudo apt-get install -y libpng-dev libmcrypt-dev && \
    sudo docker-php-ext-install gd bcmath mcrypt pdo pdo_mysql

RUN sudo apt-get remove -y libpng-dev libmcrypt-dev && sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*