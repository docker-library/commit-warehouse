import json
import logging
import pytest
import requests_mock

from platform_ import PlatformLicense
from datetime import datetime
from datetime import timedelta

logging.basicConfig(format='[%(asctime)s] %(levelname)8s - %(name)s - %(message)s')


@pytest.fixture(scope="module")
def platform():
    platform = PlatformLicense('http://localhost:8080/bonita', 'platform_login', 'platform_pass')
    return platform


def test_should_remaining_days(platform):
    # 15 days from now
    e = datetime.now() + timedelta(days=15)
    response = json.dumps({"licenseExpirationDate": datetime.strftime(e, '%Y-%m-%d')})

    with requests_mock.mock() as m:
        m.get('http://localhost:8080/bonita/platformloginservice', text='')
        m.get('http://localhost:8080/bonita/API/platform/license', text=response)

        assert platform.get_license_remaining_days() == 14


def test_should_log_debug(caplog):
    platform = PlatformLicense('http://localhost:8080/bonita', 'platform_login', 'platform_pass', log_level='DEBUG')
    response = json.dumps({"licenseExpirationDate": datetime.strftime(datetime.now(), '%Y-%m-%d')})

    with requests_mock.mock() as m:
        m.get('http://localhost:8080/bonita/platformloginservice', text='')
        m.get('http://localhost:8080/bonita/API/platform/license', text=response)

        platform.get_license_remaining_days()
        assert 'DEBUG' in caplog.text
        assert 'licenseExpirationDate' in caplog.text


def test_should_nolog(caplog):
    platform = PlatformLicense('http://localhost:8080/bonita', 'platform_login', 'platform_pass', log_level=None)
    response = json.dumps({"licenseExpirationDate": datetime.strftime(datetime.now(), '%Y-%m-%d')})

    with requests_mock.mock() as m:
        m.get('http://localhost:8080/bonita/platformloginservice', text='')
        m.get('http://localhost:8080/bonita/API/platform/license', text=response)

        platform.get_license_remaining_days()
        assert '' == caplog.text
