if "%APPVEYOR_BUILD_WORKER_IMAGE%" == "Visual Studio 2019" call "C:/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Auxiliary/Build/vcvarsall.bat" x64 || exit /b
if "%APPVEYOR_BUILD_WORKER_IMAGE%" == "Visual Studio 2017" call "C:/Program Files (x86)/Microsoft Visual Studio/2017/Community/VC/Auxiliary/Build/vcvarsall.bat" x64 || exit /b
if "%APPVEYOR_BUILD_WORKER_IMAGE%" == "Visual Studio 2015" call "C:/Program Files (x86)/Microsoft Visual Studio 14.0/VC/vcvarsall.bat" x64 || exit /b
set PATH=%APPVEYOR_BUILD_FOLDER%/openal/bin/Win64;%APPVEYOR_BUILD_FOLDER%\deps\bin;%APPVEYOR_BUILD_FOLDER%\devil;C:\Tools\vcpkg\installed\x64-windows\bin;%PATH%

rem Build LibJPEG
IF NOT EXIST %APPVEYOR_BUILD_FOLDER%\libjpeg-turbo-1.5.0.tar.gz appveyor DownloadFile http://downloads.sourceforge.net/project/libjpeg-turbo/1.5.0/libjpeg-turbo-1.5.0.tar.gz || exit /b
7z x libjpeg-turbo-1.5.0.tar.gz || exit /b
7z x libjpeg-turbo-1.5.0.tar || exit /b
ren libjpeg-turbo-1.5.0 libjpeg-turbo || exit /b
cd libjpeg-turbo || exit /b
mkdir build && cd build || exit /b
cmake .. -DCMAKE_BUILD_TYPE=Debug ^
    -DCMAKE_INSTALL_PREFIX=%APPVEYOR_BUILD_FOLDER%/deps ^
    -DWITH_JPEG8=ON ^
    -DWITH_SIMD=OFF ^
    -G Ninja || exit /b
cmake --build . --target install || exit /b
cd .. && cd .. || exit /b

rem Build libPNG
vcpkg install libpng:x64-windows

rem Build Corrade
git clone --depth 1 git://github.com/mosra/corrade.git || exit /b
cd corrade || exit /b
mkdir build && cd build || exit /b
cmake .. ^
    -DCMAKE_BUILD_TYPE=Debug ^
    -DCMAKE_INSTALL_PREFIX=%APPVEYOR_BUILD_FOLDER%/deps ^
    -DWITH_INTERCONNECT=OFF ^
    -DUTILITY_USE_ANSI_COLORS=ON ^
    -G Ninja || exit /b
cmake --build . || exit /b
cmake --build . --target install || exit /b
cd .. && cd ..

rem Build Magnum
git clone --depth 1 git://github.com/mosra/magnum.git || exit /b
cd magnum || exit /b
mkdir build && cd build || exit /b
cmake .. ^
    -DCMAKE_BUILD_TYPE=Debug ^
    -DCMAKE_INSTALL_PREFIX=%APPVEYOR_BUILD_FOLDER%/deps ^
    -DCMAKE_PREFIX_PATH=%APPVEYOR_BUILD_FOLDER%/openal ^
    -DWITH_AUDIO=ON ^
    -DWITH_DEBUGTOOLS=ON ^
    -DWITH_GL=OFF ^
    -DWITH_MESHTOOLS=OFF ^
    -DWITH_PRIMITIVES=OFF ^
    -DWITH_SCENEGRAPH=OFF ^
    -DWITH_SHADERS=OFF ^
    -DWITH_SHAPES=OFF ^
    -DWITH_TEXT=ON ^
    -DWITH_TEXTURETOOLS=ON ^
    -DWITH_ANYIMAGEIMPORTER=ON ^
    -G Ninja || exit /b
cmake --build . || exit /b
cmake --build . --target install || exit /b
cd .. && cd ..

rem Build. BUILD_GL_TESTS is enabled just to be sure, it should not be needed
rem by any plugin.
mkdir build && cd build || exit /b
cmake .. ^
    -DCMAKE_BUILD_TYPE=Debug ^
    -DCMAKE_INSTALL_PREFIX=%APPVEYOR_BUILD_FOLDER%/deps ^
    -DCMAKE_PREFIX_PATH=%APPVEYOR_BUILD_FOLDER%/openal;%APPVEYOR_BUILD_FOLDER%/devil;C:/Tools/vcpkg/installed/x64-windows ^
    -DWITH_ASSIMPIMPORTER=OFF ^
    -DWITH_DDSIMPORTER=ON ^
    -DWITH_DEVILIMAGEIMPORTER=ON ^
    -DWITH_DRFLACAUDIOIMPORTER=ON ^
    -DWITH_DRMP3AUDIOIMPORTER=ON ^
    -DWITH_DRWAVAUDIOIMPORTER=ON ^
    -DWITH_FREETYPEFONT=OFF ^
    -DWITH_HARFBUZZFONT=OFF ^
    -DWITH_JPEGIMAGECONVERTER=ON ^
    -DWITH_JPEGIMPORTER=ON ^
    -DWITH_MINIEXRIMAGECONVERTER=ON ^
    -DWITH_OPENGEXIMPORTER=ON ^
    -DWITH_PNGIMAGECONVERTER=ON ^
    -DWITH_PNGIMPORTER=ON ^
    -DWITH_STANFORDIMPORTER=ON ^
    -DWITH_STBIMAGECONVERTER=ON ^
    -DWITH_STBIMAGEIMPORTER=ON ^
    -DWITH_STBTRUETYPEFONT=ON ^
    -DWITH_STBVORBISAUDIOIMPORTER=ON ^
    -DWITH_TINYGLTFIMPORTER=ON ^
    -DBUILD_TESTS=ON ^
    -DBUILD_GL_TESTS=ON ^
    -G Ninja || exit /b
cmake --build . || exit /b
cmake --build . --target install || exit /b

rem Test
set CORRADE_TEST_COLOR=ON
ctest -V || exit /b
