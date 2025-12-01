#!/usr/bin/env python3
"""
Upload solver Docker images to the API

This script builds Docker images from the minizinc-solvers directory,
saves them as tarballs, and uploads them to the solver-director API.
"""
import sys
import subprocess
import tempfile
import requests
from pathlib import Path

API_BASE = "http://localhost/api/solverdirector/v1"
SOLVERS_DIR = Path(__file__).parent.parent.parent / "minizinc-solvers"


def build_solver_image(solver_name: str, tag: str = "latest"):
    image_name = f"{solver_name}:{tag}"

    print(f"Building {image_name}...", file=sys.stderr)

    result = subprocess.run(
        ["docker", "build", "-t", image_name, "."],
        cwd=SOLVERS_DIR,
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        raise subprocess.CalledProcessError(
            result.returncode,
            result.args,
            result.stdout,
            result.stderr
        )

    return image_name


def save_image_to_tarball(image_name: str) -> Path:

    # Create temporary file for tarball
    tmp_file = tempfile.NamedTemporaryFile(delete=False, suffix=".tar")
    tmp_file.close()
    tarball_path = Path(tmp_file.name)

    print(f"Saving {image_name} to tarball...", file=sys.stderr)

    result = subprocess.run(
        ["docker", "save", "-o", str(tarball_path), image_name],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        tarball_path.unlink(missing_ok=True)
        raise subprocess.CalledProcessError(
            result.returncode,
            result.args,
            result.stdout,
            result.stderr
        )

    return tarball_path


def upload_solver(image_name: str, solver_names: list[str], tarball_path: Path):

    print(f"Uploading {image_name} with solvers {solver_names}...", file=sys.stderr)

    with open(tarball_path, 'rb') as f:
        response = requests.post(
            f"{API_BASE}/solvers",
            data={
                "image_name": image_name,
                "names": ",".join(solver_names)
            },
            files={"file": (tarball_path.name, f, "application/x-tar")}
        )

    response.raise_for_status()
    return response.json()


def process_solver(image_name: str, solver_names: list[str]):
    tarball_path = None

    try:
        # Build the image
        full_image_name = build_solver_image(image_name)

        # Save to tarball
        tarball_path = save_image_to_tarball(full_image_name)

        # Upload to API
        result = upload_solver(image_name, solver_names, tarball_path)
        print(f"OK: {image_name} (id={result['id']}, solvers={solver_names})", file=sys.stderr)

    except subprocess.CalledProcessError as e:
        print(f"ERROR: {image_name}: Docker command failed: {e.stderr}", file=sys.stderr)
        raise
    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 400 and "already exists" in e.response.text.lower():
            print(f"SKIP: {image_name} (solver image already exists)", file=sys.stderr)
        else:
            print(f"ERROR: {image_name}: {e.response.text}", file=sys.stderr)
            raise
    except Exception as e:
        print(f"ERROR: {image_name}: {e}", file=sys.stderr)
        raise
    finally:
        # Clean up tarball
        if tarball_path and tarball_path.exists():
            tarball_path.unlink()


def main():
    if not SOLVERS_DIR.exists():
        print(f"FATAL ERROR: Solvers directory not found: {SOLVERS_DIR}", file=sys.stderr)
        sys.exit(1)

    solver_images = {
        "minizinc-solver": ["chuffed", "gecode", "ortools", "coinbc"]
    }

    try:
        for image_name, solver_names in solver_images.items():
            try:
                process_solver(image_name, solver_names)
            except Exception:
                pass

        print("Upload complete", file=sys.stderr)

    except KeyboardInterrupt:
        print("\nInterrupted by user", file=sys.stderr)
        sys.exit(130)
    except Exception as e:
        print(f"FATAL ERROR: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
