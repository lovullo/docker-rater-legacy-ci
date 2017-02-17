FROM openjdk:7

RUN apt-get update -y \
    && apt-get install -y \
        ant             \
        git             \
        openssh-client  \
        php5            \
        rsync           \
        wget            \
    && rm -rf /var/lib/apt/lists/*

# Download and install Saxon 8
RUN wget http://central.maven.org/maven2/net/sf/saxon/saxon/8.7/saxon-8.7.jar \
    && test "$( sha256sum saxon-8.7.jar | cut -d' ' -f1 )" = 211a67269e861723614700f379c77318609878fd2fc2fbd9c97420480334354c \
    && mkdir -p /usr/share/ant/lib/saxon8/ \
    && mv saxon-8.7.jar /usr/share/ant/lib/saxon8/saxon8.jar

# Download and install Saxon Dom 8
RUN wget http://central.maven.org/maven2/net/sf/saxon/saxon-dom/8.7/saxon-dom-8.7.jar \
    && test "$( sha256sum saxon-dom-8.7.jar | cut -d' ' -f1 )" = f0b62d5d9acb90813e270b688581c354c4bb075700a3dd594399d0e013ced966 \
    && mv saxon-dom-8.7.jar /usr/share/ant/lib/saxon8/saxon8-dom.jar

# Download and install Closure Compiler jar
RUN wget http://dl.google.com/closure-compiler/compiler-20161201.tar.gz \
    && test "$( sha256sum compiler-20161201.tar.gz | cut -d' ' -f1 )" = 240f3d1dbdaa4275fd234a01a3c875d2cb7ad5756147377a84247ce8a99ef3b3 \
    && tar -xzvf compiler-20161201.tar.gz closure-compiler-v20161201.jar \
    && mv -v closure-compiler-v20161201.jar /usr/share/ant/lib/closure-compiler.jar \
    && chown root:root /usr/share/ant/lib/closure-compiler.jar \
    && chmod 0644 /usr/share/ant/lib/closure-compiler.jar \
    && rm compiler-20161201.tar.gz

# Install Composer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
    && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
    && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1);  }" \
    && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer \
    && rm /tmp/composer-setup.php

# Disable host key checking from within builds as we cannot interactively accept them
# TODO: It might be a better idea to bake ~/.ssh/known_hosts into the container
RUN mkdir -p ~/.ssh
RUN printf "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config
