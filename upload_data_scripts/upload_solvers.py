#!/usr/bin/env python3
"""
Register solver images from GitHub Container Registry with the solver-director API.
Override image URLs via environment variables for local development.
"""
import os
import sys
import requests

API_BASE = "http://local/api/solverdirector/v1"
REGISTRY = "ghcr.io/portfolio-solver-platform"

# Maps image_name -> (image URL, solver names supported)
# Image URLs can be overridden via env vars for local dev, e.g.:
#   MINIZINC_SOLVERS_IMAGE=minizinc-solvers:local python upload_solvers.py
SOLVER_IMAGES = {
    "minizinc-solvers": (
        os.getenv("MINIZINC_SOLVERS_IMAGE", f"{REGISTRY}/minizinc-solvers:latest"),
        ["chuffed", "gecode", "ortools", "coinbc"],
    ),
}


def register_solver(image_name: str, image_url: str, solver_names: list[str]):
    print(f"Registering {image_name} ({image_url})...", file=sys.stderr)

    response = requests.post(
        f"{API_BASE}/solvers",
        data={
            "image_name": image_name,
            "image_url": image_url,
            "names": ",".join(solver_names),
        },
    )

    if response.status_code == 400 and "already exists" in response.text.lower():
        _update_solver_image_url(image_name, image_url)
        return

    response.raise_for_status()
    result = response.json()
    print(f"OK: {image_name} (id={result['id']}, solvers={solver_names})", file=sys.stderr)


def _update_solver_image_url(image_name: str, image_url: str):
    response = requests.patch(
        f"{API_BASE}/solvers/images/{image_name}",
        data={"image_url": image_url},
    )
    response.raise_for_status()
    print(f"UPDATED: {image_name} -> {image_url}", file=sys.stderr)


def main():
    try:
        for image_name, (image_url, solver_names) in SOLVER_IMAGES.items():
            try:
                register_solver(image_name, image_url, solver_names)
            except requests.exceptions.HTTPError as e:
                print(f"ERROR: {image_name}: {e.response.text}", file=sys.stderr)
            except Exception as e:
                print(f"ERROR: {image_name}: {e}", file=sys.stderr)

        print("Registration complete", file=sys.stderr)

    except KeyboardInterrupt:
        print("\nInterrupted by user", file=sys.stderr)
        sys.exit(130)


if __name__ == "__main__":
    main()
