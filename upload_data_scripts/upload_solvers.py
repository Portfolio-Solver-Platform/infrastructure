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
    """Build Docker image for a solver

    Args:
        solver_name: Name of the solver (e.g., "gecode", "chuffed")
        tag: Docker image tag (default: "latest")

    Returns:
        str: Full image name with tag

    Raises:
        subprocess.CalledProcessError: If docker build fails
    """
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
    """Save Docker image to a tarball

    Args:
        image_name: Full Docker image name with tag

    Returns:
        Path: Path to the created tarball

    Raises:
        subprocess.CalledProcessError: If docker save fails
    """
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


def upload_solver(name: str, tarball_path: Path):
    """Upload solver tarball to the API

    Args:
        name: Solver name
        tarball_path: Path to the tarball file

    Raises:
        requests.HTTPError: If upload fails
    """
    print(f"Uploading {name}...", file=sys.stderr)

    with open(tarball_path, 'rb') as f:
        response = requests.post(
            f"{API_BASE}/solvers",
            data={"name": name},
            files={"file": (tarball_path.name, f, "application/x-tar")}
        )

    response.raise_for_status()
    return response.json()


def process_solver(solver_name: str):
    """Build, save, and upload a solver

    Args:
        solver_name: Name of the solver to process
    """
    tarball_path = None

    try:
        # Build the image
        image_name = build_solver_image(solver_name)

        # Save to tarball
        tarball_path = save_image_to_tarball(image_name)

        # Upload to API
        result = upload_solver(solver_name, tarball_path)
        print(f"OK: {solver_name} (id={result['id']})", file=sys.stderr)

    except subprocess.CalledProcessError as e:
        print(f"ERROR: {solver_name}: Docker command failed: {e.stderr}", file=sys.stderr)
        raise
    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 400 and "already exists" in e.response.text.lower():
            print(f"SKIP: {solver_name} (solver already exists)", file=sys.stderr)
        else:
            print(f"ERROR: {solver_name}: {e.response.text}", file=sys.stderr)
            raise
    except Exception as e:
        print(f"ERROR: {solver_name}: {e}", file=sys.stderr)
        raise
    finally:
        # Clean up tarball
        if tarball_path and tarball_path.exists():
            tarball_path.unlink()


def main():
    """Main entry point"""
    if not SOLVERS_DIR.exists():
        print(f"FATAL ERROR: Solvers directory not found: {SOLVERS_DIR}", file=sys.stderr)
        sys.exit(1)

    # List of solvers to upload
    # TODO: Auto-detect solvers or read from config
    solvers = ["minizinc"]  # Default solver name based on directory structure

    try:
        for solver_name in solvers:
            try:
                process_solver(solver_name)
            except Exception:
                # Continue processing other solvers
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
