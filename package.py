import shutil
import re
from pathlib import Path

# Addon folder to package relative to this script
# (path relative to root, output archive name)
root = Path(__file__).parent
ADDON_NAME = root.name
TARGETS = [
    (Path("."), ADDON_NAME),
]

# Glob-style patterns to skip
EXCLUDES = {
    ".git",
    ".gitmodules",
    ".gitignore",
    ".gitattributes",
    ".vscode",
    "dist",
    "*.code-workspace",
    "package.py",
}


def read_version() -> str:
    """Read the semantic version from the main TOC file."""
    toc_path = root / "BetterTransmog.toc"
    if not toc_path.exists():
        return "0.0.0"

    for line in toc_path.read_text(encoding="utf-8").splitlines():
        if line.lower().startswith("## version:"):
            return line.split(":", 1)[1].strip() or "0.0.0"

    return "0.0.0"


def should_exclude(path: Path) -> bool:
    """Return True if path matches any exclusion pattern."""
    for pattern in EXCLUDES:
        if path.match(pattern) or any(part == pattern for part in path.parts):
            return True
    return False


def copy_tree(src: Path, dst: Path) -> None:
    for item in src.iterdir():
        rel = item.relative_to(src)
        if should_exclude(rel):
            continue
        target = dst / rel
        if item.is_dir():
            target.mkdir(parents=True, exist_ok=True)
            copy_tree(item, target)
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(item, target)
            
            # Ensure debug mode is disabled in all Lua files
            if item.name.endswith(".lua"):
                content = target.read_text(encoding="utf-8")
                # Replace LibRu.Module.New(..., true) with LibRu.Module.New(..., false)
                content = re.sub(
                    r'LibRu\.Module\.New\(([^,]+),\s*([^,]+),\s*([^,]+),\s*true\)',
                    r'LibRu.Module.New(\1, \2, \3, false)',
                    content
                )
                target.write_text(content, encoding="utf-8")


def package_target(target_path: Path, archive_name: str, dist_dir: Path, version: str) -> None:
    src = root / target_path
    if not src.exists():
        raise FileNotFoundError(f"Missing target: {src}")

    temp_dir = dist_dir / "_tmp" / archive_name
    if temp_dir.exists():
        shutil.rmtree(temp_dir)
    temp_dir.mkdir(parents=True)

    copy_tree(src, temp_dir)

    zip_path = dist_dir / f"{archive_name}.{version}"
    archive = shutil.make_archive(str(zip_path), "zip", temp_dir.parent, archive_name)
    shutil.rmtree(temp_dir.parent)
    print(f"Created {archive}")


def main() -> None:
    dist_dir = root / "dist"
    dist_dir.mkdir(exist_ok=True)

    version = read_version()

    for target_path, archive_name in TARGETS:
        package_target(target_path, archive_name, dist_dir, version)


if __name__ == "__main__":
    main()
