import pytest
import requests_mock

from bonita_ import BonitaLicense


@pytest.fixture(scope="module")
def license():
    license = BonitaLicense('ws_login', 'ws_pass', 'tests/wsdl_files', 'sub_login', 'sub_pass', 'sub_id', 'performance',
                            'false')
    return license


def test_wrong_ws_user(license):
    response = """
        <S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
            <S:Body>
                <S:Fault xmlns:ns4="http://www.w3.org/2003/05/soap-envelope" xmlns="">
                    <faultcode>Server</faultcode>
                        <faultstring>Authentication failed!</faultstring>
                </S:Fault>
            </S:Body>
        </S:Envelope>
       """.strip()

    with requests_mock.mock() as m:
        m.post('http://test-license.bonitasoft.com/LicenseRequest/requestLicenseWS', text=response)

        with pytest.raises(Exception) as pytest_wrapped_e:
            license._request_license('mock_reqkey', 'production', 'mock_mail', 'mock_licname',
                                     'mock_lic_company')
        assert 'Authentication failed!' in str(pytest_wrapped_e.value)


def test_wrong_request_key(license):
    response = """
    <S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
       <S:Body>
          <S:Fault xmlns:ns4="http://www.w3.org/2003/05/soap-envelope">
             <faultcode>S:Client</faultcode>
             <faultstring>Error generating license object: The request key is not valid</faultstring>
          </S:Fault>
       </S:Body>
    </S:Envelope>
           """.strip()

    with requests_mock.mock() as m:
        m.post('http://test-license.bonitasoft.com/LicenseRequest/requestLicenseWS', text=response)

        with pytest.raises(Exception) as pytest_wrapped_e:
            license._request_license('mock_reqkey', 'development', 'mock_mail', 'mock_licname',
                                     'mock_lic_company')
        assert 'The request key is not valid' in str(pytest_wrapped_e.value)


def test_wrong_sub_id(license):
    response = """
    <S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
        <S:Body>
          <S:Fault xmlns:ns4="http://www.w3.org/2003/05/soap-envelope">
             <faultcode>S:Client</faultcode>
             <faultstring>Error generating license object: This not a valid subscription</faultstring>
          </S:Fault>
       </S:Body>
    </S:Envelope>
           """.strip()

    with requests_mock.mock() as m:
        m.post('http://test-license.bonitasoft.com/LicenseRequest/requestLicenseWS', text=response)

        with pytest.raises(Exception) as pytest_wrapped_e:
            license._request_license('mock_reqkey', 'qualification', 'mock_mail', 'mock_licname',
                                     'mock_lic_company')
    assert 'This not a valid subscription' in str(pytest_wrapped_e.value)


def test_deactivate_wrong_license_file(license, tmp_path):
    lic = tmp_path / 'lic_file.lic'
    lic.write_text(u"FAKE L1c3ns3")

    response = """
        <S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
            <S:Body>
              <S:Fault xmlns:ns4="http://www.w3.org/2003/05/soap-envelope">
                 <faultcode>S:Client</faultcode>
                 <faultstring>Error deactivating license. There was an error trying to read the request key</faultstring>
              </S:Fault>
           </S:Body>
        </S:Envelope>
               """.strip()

    with requests_mock.mock() as m:
        m.post('http://test-license.bonitasoft.com/LicenseRequest/requestLicenseWS', text=response)

        with pytest.raises(Exception) as pytest_wrapped_e:
            license._deactivate_license(lic.as_posix())

    assert 'There was an error trying to read the request key' in str(pytest_wrapped_e.value)
