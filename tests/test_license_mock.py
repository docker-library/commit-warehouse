import base64
import logging
import pytest
import requests_mock

from bonita_ import BonitaLicense

logging.basicConfig(format='[%(asctime)s] %(levelname)8s - %(name)s - %(message)s')

request_license_response = """
    <?xml version="1.0"?>
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:lic="http://test-license.bonitasoft.com/">
       <soapenv:Header/>
       <soapenv:Body>
          <lic:createLicenseResponse>
             <LicenseId>
                <licenseId>18as1dds8</licenseId>
             </LicenseId>
          </lic:createLicenseResponse>
       </soapenv:Body>
    </soapenv:Envelope>
    """.strip()


@pytest.fixture(scope="module")
def license():
    license = BonitaLicense('ws_login', 'ws_pass', 'tests/wsdl_files', 'sub_login', 'sub_pass', 'sub_id', 'dummy_version',
                            'false')
    return license


def test_license_bind_service(license):
    service = license.client_wsdl.bind()
    assert service


def test_license_bind_service_port(license):
    service = license.client_wsdl.bind('RequestLicenseImplService', 'RequestLicenseImplPort')
    assert service


def test_bind_service_createLicense(license):
    service = license.client_wsdl.service.createLicense
    assert service


def test_bind_service_getLicense(license):
    service = license.client_wsdl.service.getLicense
    assert service


def test_bind_service_deactivatelicensefile(license):
    service = license.client_wsdl.service.deactivateLicenseFile
    assert service


def test_service_proxy_non_existing(license):
    with pytest.raises(AttributeError):
        assert license.client_wsdl.service.NonExisting


def test_request_license(license):
    with requests_mock.mock() as m:
        m.post('http://test-license.bonitasoft.com/LicenseRequest/requestLicenseWS', text=request_license_response)
        result = license._request_license('mock_reqkey', 'production', 'mock_mail', 'mock_licname',
                                          'mock_lic_company')

        assert result.licenseId == '18as1dds8'


def test_get_license(license):
    response = """
    <?xml version="1.0"?>
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:lic="http://test-license.bonitasoft.com/">
    <soapenv:Header/>
       <soapenv:Body>
          <lic:getLicenseResponse>
             <LicenseFile>
                <licenseFile>BccVMib8DeWpho31rhENasdkjaksdhkj</licenseFile>
                <licenseName>mock_Bonita_license.lic</licenseName>
             </LicenseFile>
          </lic:getLicenseResponse>
       </soapenv:Body>
    </soapenv:Envelope>
    """.strip()

    with requests_mock.mock() as m:
        m.post('http://test-license.bonitasoft.com/LicenseRequest/requestLicenseWS', text=response)
        license._get_license()
        assert license.licenseName == 'mock_Bonita_license.lic'
        assert license.licenseContent == base64.decodestring('BccVMib8DeWpho31rhENasdkjaksdhkj')


def test_deactivate_license(license, tmp_path):
    response = """
    <?xml version="1.0"?>
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:lic="http://test-license.bonitasoft.com/">
    <soapenv:Header/>
    <soapenv:Body>
      <lic:deactivateLicenseFileResponse>
         <DeactivationResult>
            <deactivated>true</deactivated>
            <licenseId>18as1dds8</licenseId>
            <remainingCores>0</remainingCores>
            <remainingLicenses>50</remainingLicenses>
          </DeactivationResult>
      </lic:deactivateLicenseFileResponse>
    </soapenv:Body>
    </soapenv:Envelope>
    """.strip()

    with requests_mock.mock() as m:
        m.post('http://test-license.bonitasoft.com/LicenseRequest/requestLicenseWS', text=response)
        filepath = tmp_path / 'lic_file.lic'
        filepath.write_text(u'some content')
        response = license._deactivate_license(filepath.as_posix())
        assert response.licenseId == '18as1dds8'
        assert response.deactivated


def test_request_license_log_debug(caplog):
    license = BonitaLicense('ws_login', 'ws_pass', 'tests/wsdl_files', 'sub_login', 'sub_pass', 'sub_id', 'dummy_version',
                            'false', log_level='DEBUG')

    with requests_mock.mock() as m:
        m.post('http://test-license.bonitasoft.com/LicenseRequest/requestLicenseWS', text=request_license_response)
        license._request_license('mock_reqkey', 'production', 'mock_mail', 'mock_licname',
                                 'mock_lic_company')

        assert 'DEBUG' in caplog.text
        assert 'SUCCESS! createLicense with params' in caplog.text


def test_request_license_nolog(caplog):
    license = BonitaLicense('ws_login', 'ws_pass', 'tests/wsdl_files', 'sub_login', 'sub_pass', 'sub_id', 'dummy_version',
                            'false', log_level=None)

    with requests_mock.mock() as m:
        m.post('http://test-license.bonitasoft.com/LicenseRequest/requestLicenseWS', text=request_license_response)
        license._request_license('mock_reqkey', 'production', 'mock_mail', 'mock_licname',
                                 'mock_lic_company')

        assert '' == caplog.text


def test_format_lic_version_snapshot():
    license = BonitaLicense('ws_login', 'ws_pass', 'tests/wsdl_files', 'sub_login', 'sub_pass', 'sub_id', '7.11.0-SNAPSHOT',
                            'false', log_level=None)
    assert '7.11.0' == license._format_lic_version()


def test_format_lic_version_beta():
    license = BonitaLicense('ws_login', 'ws_pass', 'tests/wsdl_files', 'sub_login', 'sub_pass', 'sub_id', '7.11.0.beta-02',
                            'false', log_level=None)
    assert '7.11.0' == license._format_lic_version()


def test_format_lic_version_release():
    license = BonitaLicense('ws_login', 'ws_pass', 'tests/wsdl_files', 'sub_login', 'sub_pass', 'sub_id', '7.11.0',
                            'false', log_level=None)
    assert '7.11.0' == license._format_lic_version()
