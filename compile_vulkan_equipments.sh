# List of packages to check
packages="build-essential git ninja-build"

update_package_index=0
# Loop through each package and check if it is installed
for pkg in $packages; do
    if dpkg -s "$pkg" 1> /dev/null; then
        echo "$pkg is already installed"
    else
        if [ $update_package_index -eq 0 ]; then
            sudo apt update
            update_package_index=1 #the script will update the package index once
        fi
        echo "$pkg is not installed"
        sudo apt install $pkg -y
    fi
done

if [ ! -d "SPIRV-Headers" ]; then
    git clone --depth 1 https://github.com/KhronosGroup/SPIRV-Headers.git --recursive
else
    echo "SPIRV-Headers folder already exists."
fi

if [ ! -d "SPIRV-Tools" ]; then
    git clone --depth 1 https://github.com/KhronosGroup/SPIRV-Tools.git --recursive
else
    echo "SPIRV-Tools folder already exists."
fi

if [ ! -d "glslang" ]; then
    git clone --depth 1 https://github.com/KhronosGroup/glslang.git --recursive
else
    echo "glslang folder already exists."
fi

if [ ! -d "shaderc" ]; then
    git clone --depth 1 https://github.com/google/shaderc.git --recursive
else
    echo "shaderc folder already exists."
fi

if [ ! -d "Vulkan-Headers" ]; then
    git clone --depth 1 https://github.com/KhronosGroup/Vulkan-Headers.git --recursive
else
    echo "Vulkan-Headers folder already exists."
fi

if [ ! -d "Vulkan-Loader" ]; then
    git clone --depth 1 https://github.com/KhronosGroup/Vulkan-Loader.git --recursive
else
    echo "Vulkan-Loader folder already exists."
fi

if [ ! -d "Vulkan-Utility-Libraries" ]; then
    git clone --depth 1 https://github.com/KhronosGroup/Vulkan-Utility-Libraries.git --recursive
else
    echo "Vulkan-Utility-Libraries folder already exists."
fi

if [ ! -d "valijson" ]; then
    git clone --depth 1 https://github.com/tristanpenman/valijson.git --recursive
else
    echo "valijson folder already exists."
fi

if [ ! -d "VulkanTools" ]; then
    git clone --depth 1 https://github.com/LunarG/VulkanTools.git --recursive
else
    echo "VulkanTools folder already exists."
fi

if [ ! -d "Vulkan-ValidationLayers" ]; then
    git clone --depth 1 https://github.com/KhronosGroup/Vulkan-ValidationLayers.git --recursive
else
    echo "Vulkan-ValidationLayers folder already exists."
fi

echo ""
echo ""
read -p "Choose CMake Generator (1 for Ninja, 2 for Make): " generator_choice
if [ "$generator_choice" -eq 1 ]; then
    CMAKE_GENERATOR="Ninja"
elif [ "$generator_choice" -eq 2 ]; then
    CMAKE_GENERATOR="Unix Makefiles"
else
    echo "Invalid CMake Generator choice. Please enter 1 or 2."
    exit 1
fi

echo ""
echo "Selected CMake Generator: $CMAKE_GENERATOR"
echo ""

echo ""
read -p "Choose build type (1 for Release, 2 for Debug): " build_choice
if [ "$build_choice" -eq 1 ]; then
    BUILD_TYPE="Release"
    COMPILE_FLAGS="-O2 -march=native"
elif [ "$build_choice" -eq 2 ]; then
    BUILD_TYPE="Debug"
    COMPILE_FLAGS="-O0 -g -Wall -ggdb"
else
    echo "Invalid build type choice. Please enter 1 or 2."
    exit 1
fi

echo ""
echo "Selected build type: $BUILD_TYPE"
echo ""

NUM_THREADS=$(($(nproc) - 2))

if [ "$NUM_THREADS" -le 0 ]; then
    NUM_THREADS=1
fi

BUILD_DIR="$(pwd)/__build_dir__/$BUILD_TYPE"
BUILD_DIR_VULKAN_SPIRV_Headers="$BUILD_DIR/__SPIRVHeaders__/$BUILD_TYPE/$LINK_TYPE"
BUILD_DIR_VULKAN_SPIRV_Tools="$BUILD_DIR/__SPIRVTools__/$BUILD_TYPE/$LINK_TYPE"
BUILD_DIR_VULKAN_GLSLANG="$BUILD_DIR/__glslang__/$BUILD_TYPE/$LINK_TYPE"
BUILD_DIR_VULKAN_SHADERC="$BUILD_DIR/__shaderc__/$BUILD_TYPE/$LINK_TYPE"
BUILD_DIR_VULKAN_HEADERS="$BUILD_DIR/__VulkanHeaders__/$BUILD_TYPE/$LINK_TYPE"
BUILD_DIR_VULKAN_LOADER="$BUILD_DIR/__VulkanLoader__/$BUILD_TYPE/$LINK_TYPE"
BUILD_DIR_VULKAN_UTILITY_LIBRARIES="$BUILD_DIR/__VulkanUtilityLibraries__/$BUILD_TYPE/$LINK_TYPE"
BUILD_DIR_VALIJSON="$BUILD_DIR/__valijson__/$BUILD_TYPE/$LINK_TYPE"
BUILD_DIR_VULKAN_TOOLS="$BUILD_DIR/__VulkanTools__/$BUILD_TYPE/$LINK_TYPE"
BUILD_DIR_VULKAN_ValidationLayers="$BUILD_DIR/__VulkanValidationLayers__/$BUILD_TYPE/$LINK_TYPE"

BUILD_OUT_DIR="$(pwd)/__build_out__/$BUILD_TYPE"

rm -rf "$BUILD_DIR"

cmake -G "$CMAKE_GENERATOR" \
    -D CMAKE_CXX_FLAGS="$COMPILE_FLAGS" \
    -D CMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -D SPIRV_HEADERS_ENABLE_TESTS=OFF \
    -D CMAKE_INSTALL_PREFIX="$BUILD_OUT_DIR/__SPIRVHeaders__" \
    -S ./SPIRV-Headers \
    -B "$BUILD_DIR_VULKAN_SPIRV_Headers"

cmake --build "$BUILD_DIR_VULKAN_SPIRV_Headers" --config "$BUILD_TYPE" --target install -j"$NUM_THREADS"
SPIRV_Headers_DIR="$BUILD_OUT_DIR/__SPIRVHeaders__/share/cmake"

SPIRV_Headers_SOURCE_DIR="$(pwd)/SPIRV-Headers"

if [ ! -d "./SPIRV-Tools/external/spirv-headers" ]; then
    mkdir "./SPIRV-Tools/external/spirv-headers"
    cp -r "$SPIRV_Headers_SOURCE_DIR"/* "./SPIRV-Tools/external/spirv-headers"
fi

cmake -G "$CMAKE_GENERATOR" \
    -D CMAKE_CXX_FLAGS="$COMPILE_FLAGS" \
    -D CMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -D SPIRV_SKIP_TESTS=ON \
    -D CMAKE_INSTALL_PREFIX="$BUILD_OUT_DIR/__SPIRVTools__" \
    -S ./SPIRV-Tools \
    -B "$BUILD_DIR_VULKAN_SPIRV_Tools"

cmake --build "$BUILD_DIR_VULKAN_SPIRV_Tools" --config "$BUILD_TYPE" --target install -j"$NUM_THREADS"
SPIRV_Tools_DIR="$BUILD_OUT_DIR/__SPIRVTools__/lib/cmake/SPIRV-Tools"
SPIRV_Tools_opt_DIR="$BUILD_OUT_DIR/__SPIRVTools__/lib/cmake/SPIRV-Tools-opt"

cmake -G "$CMAKE_GENERATOR" \
    -D CMAKE_CXX_FLAGS="$COMPILE_FLAGS" \
    -D CMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -D ENABLE_GLSLANG_JS=OFF \
    -D ALLOW_EXTERNAL_SPIRV_TOOLS=ON \
    -D CMAKE_INSTALL_PREFIX="$BUILD_OUT_DIR/__glslang__" \
    -D CMAKE_PREFIX_PATH="$SPIRV_Tools_DIR;$SPIRV_Tools_opt_DIR" \
    -S ./glslang \
    -B "$BUILD_DIR_VULKAN_GLSLANG"

cmake --build "$BUILD_DIR_VULKAN_GLSLANG" --config "$BUILD_TYPE" --target install -j"$NUM_THREADS"

glslang_SOURCE_DIR="$(pwd)/glslang"
SPIRV_Tools_SOURCE_DIR="$(pwd)/SPIRV-Tools"
cmake -G "$CMAKE_GENERATOR" \
    -D CMAKE_CXX_FLAGS="$COMPILE_FLAGS" \
    -D CMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -D SHADERC_SKIP_TESTS=ON \
    -D SHADERC_SKIP_EXAMPLES=ON \
    -D SHADERC_ENABLE_WGSL_OUTPUT=OFF \
    -D CMAKE_INSTALL_PREFIX="$BUILD_OUT_DIR/__shaderc__" \
    -D SHADERC_SPIRV_TOOLS_DIR="$SPIRV_Tools_SOURCE_DIR" \
    -D SHADERC_SPIRV_HEADERS_DIR="$SPIRV_Headers_SOURCE_DIR" \
    -D SHADERC_GLSLANG_DIR="$glslang_SOURCE_DIR" \
    -S ./shaderc \
    -B "$BUILD_DIR_VULKAN_SHADERC"

cmake --build "$BUILD_DIR_VULKAN_SHADERC" --config "$BUILD_TYPE" --target install -j"$NUM_THREADS"

cmake -G "$CMAKE_GENERATOR" \
    -D VULKAN_HEADERS_ENABLE_TESTS=OFF \
    -D CMAKE_INSTALL_PREFIX="$BUILD_OUT_DIR/__VulkanHeaders__" \
    -S ./Vulkan-Headers \
    -B "$BUILD_DIR_VULKAN_HEADERS"

cmake --build "$BUILD_DIR_VULKAN_HEADERS" --config "$BUILD_TYPE" --target install -j"$NUM_THREADS"
VulkanHeaders_DIR="$BUILD_OUT_DIR/__VulkanHeaders__/share/cmake"

cmake -G "$CMAKE_GENERATOR" \
    -D CMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -D CMAKE_C_FLAGS="$COMPILE_FLAGS" \
    -D BUILD_TESTS=OFF \
    -D BUILD_WERROR=OFF \
    -D CMAKE_INSTALL_PREFIX="$BUILD_OUT_DIR/__VulkanLoader__" \
    -D CMAKE_PREFIX_PATH="$VulkanHeaders_DIR" \
    -S ./Vulkan-Loader \
    -B "$BUILD_DIR_VULKAN_LOADER"

cmake --build "$BUILD_DIR_VULKAN_LOADER" --config "$BUILD_TYPE" --target install -j"$NUM_THREADS"
VulkanLoader_DIR="$BUILD_OUT_DIR/__VulkanLoader__/lib/cmake"

cmake -G "$CMAKE_GENERATOR" \
    -D CMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -D CMAKE_CXX_FLAGS="$COMPILE_FLAGS" \
    -D CMAKE_INSTALL_PREFIX="$BUILD_OUT_DIR/__VulkanUtilityLibraries__" \
    -D CMAKE_PREFIX_PATH="$VulkanHeaders_DIR" \
    -S ./Vulkan-Utility-Libraries \
    -B "$BUILD_DIR_VULKAN_UTILITY_LIBRARIES"

cmake --build "$BUILD_DIR_VULKAN_UTILITY_LIBRARIES" --config "$BUILD_TYPE" --target install -j"$NUM_THREADS"
VulkanUtilityLibraries_DIR="$BUILD_OUT_DIR/__VulkanUtilityLibraries__/lib/cmake"

cmake -G "$CMAKE_GENERATOR" \
    -D CMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -D CMAKE_CXX_FLAGS="$COMPILE_FLAGS" \
    -D CMAKE_INSTALL_PREFIX="$BUILD_OUT_DIR/__valijson__" \
    -S ./valijson \
    -B "$BUILD_DIR_VALIJSON"

cmake --build "$BUILD_DIR_VALIJSON" --config "$BUILD_TYPE" --target install -j"$NUM_THREADS"
valijson_DIR="$BUILD_OUT_DIR/__valijson__/lib/cmake"

cmake -G "$CMAKE_GENERATOR" \
    -D CMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -D CMAKE_CXX_FLAGS="$COMPILE_FLAGS" \
    -D BUILD_LAYERMGR=OFF \
    -D BUILD_VIA=OFF \
    -D CMAKE_INSTALL_PREFIX="$BUILD_OUT_DIR/__VulkanTools__" \
    -D CMAKE_PREFIX_PATH="$VulkanHeaders_DIR;$VulkanLoader_DIR;$VulkanUtilityLibraries_DIR;$valijson_DIR" \
    -S ./VulkanTools \
    -B "$BUILD_DIR_VULKAN_TOOLS"

cmake --build "$BUILD_DIR_VULKAN_TOOLS" --config "$BUILD_TYPE" --target install -j"$NUM_THREADS"

cmake -G "$CMAKE_GENERATOR" \
    -D CMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -D CMAKE_CXX_FLAGS="$COMPILE_FLAGS" \
    -D CMAKE_INSTALL_PREFIX="$BUILD_OUT_DIR/__VulkanValidationLayers__" \
    -D CMAKE_PREFIX_PATH="$VulkanHeaders_DIR;$VulkanUtilityLibraries_DIR;$SPIRV_Headers_DIR;$SPIRV_Tools_DIR;$SPIRV_Tools_opt_DIR" \
    -S ./Vulkan-ValidationLayers \
    -B "$BUILD_DIR_VULKAN_ValidationLayers"

cmake --build "$BUILD_DIR_VULKAN_ValidationLayers" --config "$BUILD_TYPE" --target install -j"$NUM_THREADS"
