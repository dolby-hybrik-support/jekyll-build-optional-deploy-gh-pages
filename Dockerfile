FROM jekyll/jekyll:3.8.6

# Set default locale for the environment	
ENV LC_ALL C.UTF-8	
ENV LANG en_US.UTF-8	
ENV LANGUAGE en_US.UTF-8	

RUN sudo apt-get update && apt-get -y install awscli

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["sh", "/entrypoint.sh"]
