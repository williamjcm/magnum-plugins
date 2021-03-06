#
#   This file is part of Magnum.
#
#   Copyright © 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019
#             Vladimír Vondruš <mosra@centrum.cz>
#   Copyright © 2019 Guillaume Jacquemin <williamjcm@users.noreply.github.com>
#
#   Permission is hereby granted, free of charge, to any person obtaining a
#   copy of this software and associated documentation files (the "Software"),
#   to deal in the Software without restriction, including without limitation
#   the rights to use, copy, modify, merge, publish, distribute, sublicense,
#   and/or sell copies of the Software, and to permit persons to whom the
#   Software is furnished to do so, subject to the following conditions:
#
#   The above copyright notice and this permission notice shall be included
#   in all copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
#   THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
#   DEALINGS IN THE SOFTWARE.
#

if(CORRADE_TARGET_EMSCRIPTEN OR CORRADE_TARGET_ANDROID)
    set(DRWAVAUDIOIMPORTER_TEST_DIR ".")
else()
    set(DRWAVAUDIOIMPORTER_TEST_DIR ${CMAKE_CURRENT_SOURCE_DIR})
endif()

# CMake before 3.8 has broken $<TARGET_FILE*> expressions for iOS (see
# https://gitlab.kitware.com/cmake/cmake/merge_requests/404) and since Corrade
# doesn't support dynamic plugins on iOS, this sorta works around that. Should
# be revisited when updating Travis to newer Xcode (current has CMake 3.6).
if(NOT BUILD_PLUGINS_STATIC)
    set(DRWAVAUDIOIMPORTER_PLUGIN_FILENAME $<TARGET_FILE:DrWavAudioImporter>)

    # First replace ${} variables, then $<> generator expressions
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/configure.h.cmake
                   ${CMAKE_CURRENT_BINARY_DIR}/configure.h.in)
    file(GENERATE OUTPUT $<TARGET_FILE_DIR:DrWavAudioImporterTest>/configure.h
        INPUT ${CMAKE_CURRENT_BINARY_DIR}/configure.h.in)
else()
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/configure.h.cmake
                   ${CMAKE_CURRENT_BINARY_DIR}/configure.h)
endif()

corrade_add_test(DrWavAudioImporterTest DrWavImporterTest.cpp
    LIBRARIES Magnum::Audio
    FILES
        wrongSignature.wav
        unsupportedChannelCount.wav
        unsupportedBitRate.wav

        invalidPadding.wav
        invalidLength.wav
        invalidDataChunk.wav
        invalidFactChunk.wav

        zeroSamples.wav

        mono8ALaw.wav
        mono8MuLaw.wav
        mono8.wav
        mono16.wav
        mono24.wav

        stereo8.wav
        stereo8ALaw.wav
        stereo8MuLaw.wav
        stereo12.wav
        stereo16.wav
        stereo24.wav
        stereo32.wav

        mono32f.wav
        stereo32f.wav
        stereo64f.wav

        surround51Channel16.wav
        surround71Channel24.wav

        extension8.wav
        extensionALaw.wav
        extensionMuLaw.wav
        extension12.wav
        extension16.wav
        extension24.wav
        extension32.wav

        extension32f.wav
        extension64f.wav)
if(NOT BUILD_PLUGINS_STATIC)
    target_include_directories(DrWavAudioImporterTest PRIVATE $<TARGET_FILE_DIR:DrWavAudioImporterTest>)
else()
    target_include_directories(DrWavAudioImporterTest PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
    target_link_libraries(DrWavAudioImporterTest PRIVATE DrWavAudioImporter)
endif()
set_target_properties(DrWavAudioImporterTest PROPERTIES FOLDER "MagnumPlugins/DrWavAudioImporter/Test")
