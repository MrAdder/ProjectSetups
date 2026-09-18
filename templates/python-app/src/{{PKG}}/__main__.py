"""Entry point: `python -m {{PKG}}`."""

import logging
import os

log = logging.getLogger(__name__)


def main() -> None:
    logging.basicConfig(level=os.environ.get("LOG_LEVEL", "INFO").upper())
    log.info("{{NAME}} starting")


if __name__ == "__main__":
    main()
