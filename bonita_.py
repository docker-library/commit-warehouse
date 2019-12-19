import datetime
import fnmatch
import logging
import logging.config
import os

from collections import OrderedDict
from os.path import basename
from requests import Session
from retrying import retry
from zeep import Client
from zeep.transports import Transport
from zeep.wsdl.bindings.soap import Fault


class BonitaLicense(object):
    license_types = ['production', 'qualification', 'development', 'trial', 'training', 'partner', 'internal']


    def __init__(self, ws_login, ws_password, ws_url, sub_login, sub_password, sub_id, bonita_version,
                 disable_ssl_check=False, log_level='INFO'):

        self.logger = logging.getLogger(__name__)
        if log_level is None:
            self.logger.propagate = False
            self.logger.addHandler(logging.NullHandler())
        elif log_level is not 'INFO':
            self.logger.setLevel(logging.getLevelName(log_level))

        self.ws_login = ws_login
        self.ws_password = ws_password
        self.ws_url = ws_url
        self.sub_login = sub_login
        self.sub_password = sub_password
        self.sub_id = sub_id
        self.disable_ssl_check = disable_ssl_check
        self.bonita_version = bonita_version

        # attributes from webservice response
        self.licenseId = None
        self.licenseEndDate = None
        self.licenseName = None
        self.licenseContent = None

        self.client_wsdl = self._create_wsdl_session()


    def _create_wsdl_session(self):
        session = Session()
        session.auth = (self.ws_login, self.ws_password)
        session.verify = not self.disable_ssl_check
        transport = Transport(timeout=10, session=session)
        try:
            wsdl = Client(self.ws_url + '/LicenseRequest/requestLicenseWS?wsdl', None, transport)
            return wsdl
        except BaseException:
            raise Exception('There is an error in the Web Service URL or the service is down.')


    def _format_lic_version(self):
        return '.'.join(self.bonita_version.replace('-', '.').split('.', 3)[:3])


    def _request_license(self, request_key, lic_type, lic_email, lic_name, lic_company,
                         disable_checks=None):

        if lic_type not in BonitaLicense.license_types:
            raise Exception('Unexpected license type - Possible values are {}'.format(BonitaLicense.license_types))

        request_date = datetime.date.today()
        end_date = request_date + datetime.timedelta(days=40)

        # convert bonita_version to a version known from license webservice
        # eg. 7.8.0.beta-02 --> 7.8.0 / 7.8.3-SNAPSHOT --> 7.8.3
        lic_version = self._format_lic_version()

        params = OrderedDict()
        params['subscriptionId'] = self.sub_id
        params['requestProductVersion'] = 'BOS-SP-' + lic_version
        params['requestKey'] = request_key
        params['requestLicenseType'] = lic_type
        params['requestStartDate'] = str(request_date)
        params['requestEndDate'] = str(end_date)
        params['requestLicenseeEmail'] = lic_email
        params['notifyEmail'] = lic_email
        params['requestLicenseeName'] = lic_name
        params['requestLicenseeCompany'] = lic_company

        if disable_checks is not None:
            params['disableChecks'] = disable_checks

        params['login'] = self.sub_login
        params['password'] = self.sub_password

        try:
            ws_response = self.client_wsdl.service.createLicense(LicenseRequest=params)
            if ws_response is None:
                raise Exception('Incorrect webservice username or password')
            self.licenseId = ws_response.licenseId
            self.licenseEndDate = ws_response.licenseEndDate

            self.logger.debug('Response: {}'.format(ws_response))
            self.logger.debug('SUCCESS! createLicense with params: {}'.format(params))

            return ws_response

        except BaseException as e:
            self.logger.error(e.message)
            raise Exception(e.message)


    @retry(wait_exponential_multiplier=2000, wait_exponential_max=32000, stop_max_delay=150000)
    def _get_license(self):
        params = {'licenseId': self.licenseId, 'login': self.sub_login, 'password': self.sub_password,
                  'subscriptionId': self.sub_id}
        try:
            ws_response = self.client_wsdl.service.getLicense(params)
            self.licenseName = ws_response.licenseName
            self.licenseContent = ws_response.licenseFile

            self.logger.debug('Response: {}'.format(ws_response))
            self.logger.debug('SUCCESS! getLicense with params: {}'.format(params))

            return ws_response

        except Fault:
            raise Exception('The license is being created...')
        except BaseException as e:
            self.logger.error(e.message)
            raise Exception('Error while getting license - Contact support.')


    def _deactivate_license(self, filepath):
        # read license file
        self.licenseName = basename(filepath)
        with open(filepath, 'r') as f:
            self.licenseContent = f.read()

        # convert bonita_version to a version known from license webservice
        # eg. 7.8.0.beta-02 --> 7.8 / 7.8.3-SNAPSHOT --> 7.8
        lic_version = '.'.join(self.bonita_version.split('.', 2)[:2])

        params = {'subscriptionId': self.sub_id, 'deactivationFile': self.licenseContent, 'login': self.sub_login,
                  'password': self.sub_password, 'fileName': self.licenseName, 'version': lic_version}

        try:
            ws_response = self.client_wsdl.service.deactivateLicenseFile(DeactivateRequestFile=params)
            if ws_response is None:
                raise Exception('Error while deactivating license. Please contact support.')
            self.remainingCores = ws_response.remainingCores
            self.remainingLicenses = ws_response.remainingLicenses

            self.logger.info('Deactivated: {} - Remaining licenses: {}'.format(filepath, self.remainingLicenses))
            self.logger.debug('SUCCESS! deactivateLicenseFile with params: {}'.format(params))

            return ws_response

        except BaseException as e:
            self.logger.error(e.message)
            raise Exception(e.message)


    def generate(self, request_key, lic_type, lic_email, lic_name, lic_company, disable_checks=None,
                 output_dir='/tmp'):
        """
        Request a new license and get the generated file.

        """
        self._request_license(request_key, lic_type, lic_email, lic_name, lic_company, disable_checks)
        self._get_license()

        # write license content to file
        lic_path = os.path.join(output_dir, self.licenseName)
        with open(lic_path, 'w') as f:
            f.write(self.licenseContent)
        self.logger.info('Saved: {}'.format(lic_path))

        self.licensePath = lic_path


    def revoke(self, filepath):
        """
        Deactivate a license and remove file.

        """
        # check file can be deleted
        if not os.access(filepath, os.W_OK) or not os.access(os.path.dirname(filepath), os.W_OK):
            raise Exception('File [{}] must be deletable in order to revoke license'.format(filepath))

        self._deactivate_license(filepath)
        os.remove(filepath)


    def renew(self, lic_dir, request_key, lic_type, lic_email, lic_name, lic_company,
              disable_checks=None):
        """
        Renew licenses:
        - deactivate licenses in lic_dir
        - request a new license and save to lic_dir
        - remove old licenses
        """
        # ensure license directory and files are deletable
        lic_files = [os.path.join(lic_dir, f) for f in os.listdir(lic_dir) if fnmatch.fnmatch(f, "*.lic")]
        if not os.access(lic_dir, os.W_OK):
            raise Exception('Directory [{}] must be writable in order to revoke licenses'.format(lic_dir))
        for filepath in lic_files:
            if not os.access(filepath, os.W_OK):
                raise Exception('File [{}] must be deletable in order to revoke license'.format(filepath))

        # deactivate old licenses
        for filepath in lic_files:
            self._deactivate_license(filepath)

        # request new license
        self.generate(request_key, lic_type, lic_email, lic_name, lic_company,
                      disable_checks=disable_checks, output_dir=lic_dir)

        # remove old licenses
        for filepath in lic_files:
            if basename(filepath) != basename(self.licensePath):
                os.remove(filepath)
