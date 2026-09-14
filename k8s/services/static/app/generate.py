#!/usr/bin/env python3
from pathlib import Path

import jinja2
import yaml


def main():
    root_dir = Path(__file__).parent
    context = yaml.safe_load((root_dir / "context.yml").read_text())
    for file in root_dir.glob("**/*.j2"):
        env = jinja2.Environment(lstrip_blocks=True)
        rendered = env.from_string(file.read_text()).render(**context)
        Path(str(file).removesuffix(".j2")).write_text(rendered)


if __name__ == "__main__":
    main()
