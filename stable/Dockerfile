FROM php:7.1-apache

# System Dependencies.
RUN apt-get update && apt-get install -y \
		git \
		imagemagick \
		libicu-dev \
	--no-install-recommends && rm -r /var/lib/apt/lists/*

# Install the PHP extensions we need
RUN docker-php-ext-install mbstring mysqli opcache intl

# Install the default object cache.
RUN pecl channel-update pecl.php.net \
	&& pecl install apcu-5.1.8 \
	&& docker-php-ext-enable apcu

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# SQLite Directory Setup
RUN mkdir -p /var/www/data \
	&& chown -R www-data:www-data /var/www/data

# Version
ENV MEDIAWIKI_MAJOR_VERSION 1.29
ENV MEDIAWIKI_BRANCH REL1_29
ENV MEDIAWIKI_VERSION 1.29.0
ENV MEDIAWIKI_SHA512 3b77d04f13488b2a602d9030a4833c881188c93e2708ea7941d9e82f7a7215f3028695f396914da09ae1288cb9e980cc04f78559edaff6559e3d50b0c47afeb3

# MediaWiki setup
RUN curl -fSL "https://releases.wikimedia.org/mediawiki/${MEDIAWIKI_MAJOR_VERSION}/mediawiki-${MEDIAWIKI_VERSION}.tar.gz" -o mediawiki.tar.gz \
	&& echo "${MEDIAWIKI_SHA512} *mediawiki.tar.gz" | sha512sum -c - \
	&& tar -xz --strip-components=1 -f mediawiki.tar.gz \
	&& rm mediawiki.tar.gz \
	&& chown -R www-data:www-data extensions skins cache images
