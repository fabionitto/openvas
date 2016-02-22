FROM 	fabionitto/openvas-base-libraries:8.0.6
MAINTAINER Fabio Nitto "fabio.nitto@gmail.com"

# Include Environment for certs configuration?
# ENV OPENVAS_CERT_DATA
ENV OPENVAS_ADMIN_USER     admin \
    OPENVAS_ADMIN_PASSWORD openvas

RUN     apt-get update && apt-get -y install \
        libsqlite3-dev \
        rsync \
        sqlite3 \
        xsltproc && \
        apt-get clean

RUN 	mkdir /src && \
	cd /src && \
	wget http://wald.intevation.org/frs/download.php/2266/openvas-scanner-5.0.5.tar.gz -O openvas-scanner.tar.gz 2> /dev/null && \
	tar xvzf openvas-scanner.tar.gz && \
	cd /src/openvas-scanner-* && \
	mkdir build && \
	cd build && \
	cmake .. && \
	make && \
	make install && \
	make rebuild_cache 

RUN     cd /src && \
        wget http://wald.intevation.org/frs/download.php/2270/openvas-manager-6.0.7.tar.gz -O openvas-manager.tar.gz 2> /dev/null && \
        tar xvzf openvas-manager.tar.gz && \
        cd /src/openvas-manager-* && \
        mkdir build && \
        cd build && \
        cmake .. && \
        make && \
        make install && \
        make rebuild_cache && \
        cd / && \
        rm -rf /src 

RUN 	ldconfig
RUN	openvas-mkcert -q -f && \
	openvas-mkcert-client -n -i

RUN	openvas-nvt-sync
RUN	sed -i "s/SPLIT_PART_SIZE=0/SPLIT_PART_SIZE=2048/g" `which openvas-scapdata-sync` && \
	openvas-scapdata-sync
RUN	openvas-certdata-sync

RUN	openvassd && \
	openvasmd --rebuild -v --progress && \
	openvasmd --create-user=${OPENVAS_ADMIN_USER} --role=Admin && \
	openvasmd --user=${OPENVAS_ADMIN_USER} --new-password=${OPENVAS_ADMIN_PASSWORD}

EXPOSE 9391

COPY start.sh /home/coreos/

