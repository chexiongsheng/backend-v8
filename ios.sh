VERSION=$1
[ -z "$GITHUB_WORKSPACE" ] && GITHUB_WORKSPACE="$( cd "$( dirname "$0" )"/.. && pwd )"

cd ~
echo "=====[ Getting Depot Tools ]====="	
git clone -b chrome/4147 -q https://chromium.googlesource.com/chromium/tools/depot_tools.git
export DEPOT_TOOLS_UPDATE=0
export PATH=$(pwd)/depot_tools:$PATH
gclient

mkdir v8
cd v8

echo "=====[ Fetching V8 ]====="
fetch v8
echo "target_os = ['ios']" >> .gclient
cd ~/v8/v8
git checkout refs/tags/$VERSION
gclient sync

# echo "=====[ Patching V8 ]====="
# git apply --cached $GITHUB_WORKSPACE/patches/builtins-puerts.patches
# git checkout -- .

echo "=====[ add ArrayBuffer_New_Without_Stl ]====="
node $GITHUB_WORKSPACE/node-script/add_arraybuffer_new_without_stl.js .

echo "=====[ Building V8 ]====="
python ./tools/dev/v8gen.py arm64.release -vv -- '
v8_use_external_startup_data = true
v8_use_snapshot = true
v8_enable_i18n_support = false
is_debug = false
v8_static_library = true
ios_enable_code_signing = false
target_os = "ios"
target_cpu = "arm64"
v8_enable_pointer_compression = false
libcxx_abi_unstable = false
'
tar cvf out.gn.tar out.gn

mkdir -p output/v8/Lib/iOS/arm64
cp out.gn.tar output/v8/Lib/iOS/arm64/

