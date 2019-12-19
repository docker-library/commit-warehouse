import logging

from bonita_ import BonitaLicense
from platform_ import PlatformLicense
from logging.config import dictConfig

__version__ = '1.3.2'

dictConfig(
    dict(
        version=1,
        formatters={
            'bonitaformat': {
                'format': '[%(asctime)s] %(levelname)8s - %(name)s - %(message)s'
            }
        },
        handlers={
            'console': {
                'class': 'logging.StreamHandler',
                'formatter': 'bonitaformat'
            }
        },
        root={
            'handlers': ['console'],
            'level': logging.INFO
        }
    )
)
