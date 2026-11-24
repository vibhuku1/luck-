#!/bin/zsh
set -euo pipefail

script_dir="${0:A:h}"
project_dir="${script_dir:h}"
app_path="${project_dir}/dist/Nazar Dangle.app"

cd "${project_dir}"
swift build -c release --arch arm64
binary_path="$(swift build -c release --arch arm64 --show-bin-path)/NazarDangle"
resource_bundle_path="$(dirname "${binary_path}")/NazarDangle_NazarDangle.bundle"

if [[ ! -x "${binary_path}" ]]; then
  echo "Could not find the compiled NazarDangle executable." >&2
  exit 1
fi

if [[ ! -d "${resource_bundle_path}" ]]; then
  echo "Could not find the compiled Nazar Dangle resources." >&2
  exit 1
fi

rm -rf "${app_path}"
mkdir -p "${app_path}/Contents/MacOS" "${app_path}/Contents/Resources"
cp "${binary_path}" "${app_path}/Contents/MacOS/NazarDangle"
cp -R "${resource_bundle_path}" "${app_path}/Contents/Resources/"
cp "Resources/Info.plist" "${app_path}/Contents/Info.plist"
codesign --force --sign - "${app_path}"

echo "Built: ${app_path}"
