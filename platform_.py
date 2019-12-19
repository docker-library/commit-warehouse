import logging
import requests

from datetime import datetime


class PlatformLicense(object):

    def __init__(self, bonita_url, platform_username, platform_password, log_level='INFO'):
        self.bonita_url = bonita_url
        self.platform_username = platform_username
        self.platform_password = platform_password

        self.logger = logging.getLogger(__name__)
        if log_level is None:
            self.logger.propagate = False
            self.logger.addHandler(logging.NullHandler())
        elif log_level is not 'INFO':
            self.logger.setLevel(logging.getLevelName(log_level))


    def get_license_remaining_days(self):
        """
        Get the number of remaining days a license is valid using Bonita platform license API.
        :return: the number of remaining days as a floored integer
        """
        try:
            login = requests.get(self.bonita_url + '/platformloginservice',
                                 params={'username': self.platform_username, 'password': self.platform_password,
                                         'redirect': 'false'})

            if login.status_code != 200:
                self.logger.debug('HTTP status code: %s' % login.status_code)
                raise Exception('Error while loging in Platform')

            response = requests.get(self.bonita_url + '/API/platform/license', cookies=login.cookies)

            self.logger.debug(response.json())
            expiration_date = datetime.strptime(response.json()['licenseExpirationDate'], '%Y-%m-%d')
            remaining_days = (expiration_date - datetime.now()).days

            return remaining_days

        except BaseException as e:
            self.logger.error(e.message)
            raise Exception(e.message)
