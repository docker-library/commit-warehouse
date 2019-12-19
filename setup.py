import re
import sys

from setuptools import setup

with open("__init__.py") as f:
    version = re.search(r"__version__ = \'(.*?)\'", f.read()).group(1)

setup_requires = ['pytest-runner'] if 'test' in sys.argv else []

install_requires = [
    'appdirs == 1.4.3',
    'cached-property == 1.3.1',
    'defusedxml == 0.5.0',
    'isodate == 0.6.0',
    'lxml == 4.2.5',
    'certifi == 2018.4.16',
    'chardet == 3.0.4',
    'idna == 2.6',
    'urllib3 == 1.22',
    'requests == 2.20.0',
    'requests-toolbelt == 0.8.0',
    'six == 1.11.0',
    'pytz == 2017.2',
    'retrying == 1.3.3',
    'zeep == 2.5.0'
]

tests_require = [
    'pytest == 3.9.2',
    'requests_mock'
]

setup(
    name='bonita-license',
    version=version,
    description='A Python client to Bonita license web services',
    packages=['bonita_license'],
    package_dir={'bonita_license': '.'},
    setup_requires=setup_requires,
    install_requires=install_requires,
    tests_require=tests_require,
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Intended Audience :: Developers',
        'License :: Bonitasoft',
        'Programming Language :: Python :: 2.7'
    ]
)
