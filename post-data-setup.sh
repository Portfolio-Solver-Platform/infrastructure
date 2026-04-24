#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <problems-dir>" >&2
    exit 1
fi

PROBLEMS_DIR="$1"
REGISTRY="ghcr.io/portfolio-solver-platform"

# --- Step 1: Ensure minizinc group exists ---
echo "=== Creating minizinc group ==="
group_id=$(psp groups list --json | jq -r '.[] | select(.name == "minizinc") | .id')
if [ -z "$group_id" ]; then
    group_id=$(psp groups create minizinc --description "Minizinc formats" --json | jq -r '.id')
    echo "Created (id=$group_id)"
else
    echo "Already exists (id=$group_id)"
fi

# --- Step 2: Register solvers ---
echo "=== Registering solvers ==="
image_url="${MINIZINC_SOLVERS_IMAGE:-$REGISTRY/minizinc-solvers:latest}"
if ! psp solvers register minizinc-solvers "$image_url" --names "chuffed,cp-sat,coinbc,choco,dexter,huub,izplus,parasol,picat,pumpkin,yuck" 2>/dev/null; then
    psp solvers update-image minizinc-solvers "$image_url"
fi

# --- Step 3: Upload problems ---
echo "=== Uploading problems ==="
for dir in "$PROBLEMS_DIR"/*/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")

    # Skip dirs with unsupported files
    skip=false
    for file in "$dir"*; do
        [ -f "$file" ] || continue
        case "$(basename "$file")" in
            *.mzn|*.dzn|LICENSE|README*) ;;
            *) echo "SKIP: $name (unsupported file: $(basename "$file"))" >&2; skip=true; break ;;
        esac
    done
    $skip && continue

    # Collect .mzn and .dzn files
    mzn_files=("$dir"*.mzn); [[ -e "${mzn_files[0]}" ]] || mzn_files=()
    dzn_files=("$dir"*.dzn); [[ -e "${dzn_files[0]}" ]] || dzn_files=()
    mzn_count=${#mzn_files[@]}
    dzn_count=${#dzn_files[@]}

    if [ "$mzn_count" -eq 1 ] && [ "$dzn_count" -gt 0 ]; then
        # Single .mzn model + .dzn data files as instances
        problem_id=$(psp problems create "$name" --group "$group_id" --json | jq -r '.id') || {
            echo "SKIP: $name (already exists or error)" >&2; continue
        }
        psp problems upload-file "$problem_id" "${mzn_files[0]}"
        for dzn in "${dzn_files[@]}"; do
            psp instances upload "$problem_id" "$dzn"
        done
    elif [ "$mzn_count" -gt 1 ] && [ "$dzn_count" -eq 0 ]; then
        # Multiple self-contained .mzn instances
        problem_id=$(psp problems create "$name" --group "$group_id" --json | jq -r '.id') || {
            echo "SKIP: $name (already exists or error)" >&2; continue
        }
        for mzn in "${mzn_files[@]}"; do
            psp instances upload "$problem_id" "$mzn"
        done
    else
        echo "SKIP: $name ($mzn_count .mzn, $dzn_count .dzn)" >&2
    fi
done


echo "=== Done ==="
