#!/usr/bin/env python3
"""
Create default groups via API
Run with: python scripts/upload_groups.py
"""
import requests
import sys
import psp.config as psp_config
from psp.auth import get_access_token


def _api_base() -> str:
    return psp_config.load()["base_url"].rstrip("/") + "/api/solverdirector/v1"


def _headers() -> dict:
    return {"Authorization": f"Bearer {get_access_token()}"}


def create_group(name: str, description: str):
    """Create a group via API"""
    url = f"{_api_base()}/groups"
    data = {"name": name, "description": description}

    try:
        response = requests.post(url, json=data, headers=_headers())
        if response.status_code == 201:
            result = response.json()
            print(f"✓ Created group '{name}' with ID: {result['id']}")
        elif response.status_code == 400 and "already exists" in response.text:
            print(f"✓ Group '{name}' already exists")
        else:
            print(f"✗ Failed to create group '{name}': {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"✗ Error creating group '{name}': {e}")
        return False

    return True


def main():
    print("Creating groups...")

    # Create minizinc group
    success = create_group("minizinc", "Minizinc formats")

    if success:
        print("Done!")
        sys.exit(0)
    else:
        print("Failed!")
        sys.exit(1)


if __name__ == "__main__":
    main()
