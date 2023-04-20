#!/usr/bin/env bash

# Exits as soon as any line fails.
set -euo pipefail

source ci/scripts/common.sh

############# INSTALL NEXMARK BENCH

pushd ..
git clone https://"$GITHUB_TOKEN"@github.com/risingwavelabs/nexmark-bench.git
pushd nexmark-bench
make install
cp /usr/local/cargo/bin/nexmark-server ./nexmark-server
buildkite-agent artifact upload ./nexmark-server
popd
popd

############# SETUP RW

# FIXME(kwannoel): Not sure if risingwave_java_binding is needed
echo "--- Build Rust components"
cargo build \
    -p risingwave_cmd_all \
    -p risedev \
    -p risingwave_java_binding \
    --features "static-link static-log-level" --profile release

# the file name suffix of artifact for risingwave_java_binding is so only for linux. It is dylib for MacOS
artifacts=(risingwave risedev-dev librisingwave_java_binding.so)

echo "--- Show link info"
ldd target/release/risingwave

# Namespacing is required (by suffixing bench: XXX-bench), so we can upload and download buildkite artifacts.
echo "--- Upload artifacts"
echo -n "${artifacts[*]}" | parallel -d ' ' "mv target/release/{} ./{}-bench && buildkite-agent artifact upload ./{}-bench"

echo "--- Show sccache stats"
sccache --show-stats