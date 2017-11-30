pipeline {
    agent none
    stages {
        stage('Build and Test') {
            parallel {
                stage('Linux/GCC') {
                    agent {
                        label 'linux && cmake && gcc'
                    }
                    steps {
                        sh '''
                            rm -rf build/
                            mkdir build
                            cd build
                            gcc --version
                            cmake -G "Unix Makefiles" ../
                            make

                        '''
                    }
                }
                stage('Linux/Clang') {
                    agent {
                        label 'linux && cmake && clang'
                    }
                    steps {
                        sh '''
                            export CC=clang
                            export CXX=clang++
                            rm -rf build/
                            mkdir build
                            cd build
                            clang --version
                            cmake -G "Unix Makefiles" ../
                            make

                        '''
                    }
                }
                stage('Windows/GCC') {
                    agent {
                        label 'windows && cmake && gcc'
                    }
                    steps {
                        bat'''
                            set PATH=%PATH%;%MINGW64%;
                            rmdir /Q /S build
                            mkdir build
                            cd build
                            gcc --version
                            call cmake -G "MinGW Makefiles" ../
                            mingw32-make

                        '''
                    }
                }
                stage('Windows/Clang') {
                    agent {
                        label 'windows && cmake && clang'
                    }
                    steps {
                        bat'''
                            set PATH=%PATH%;%MINGW64%;
                            set CC=clang
                            set CXX=clang++
                            rmdir /Q /S build
                            mkdir build
                            cd build
                            clang --version
                            call cmake -G "MinGW Makefiles" ../
                            mingw32-make

                        '''
                    }
                }
                stage('Windows/MSVC2015') {
                    agent {
                        label 'windows && cmake && msvc2015'
                    }
                    steps {
                        bat '''
                            set VSCMD_START_DIR=%CD%
                            call "%MSVC2017_BUILD_TOOLS%" x64 %WIN10_SDK_VER% -vcvars_ver=14.0
                            set PATH=%PATH%;%MINGW64%;
                            rmdir /Q /S build
                            mkdir build
                            cd build
                            call cmake -G "NMake Makefiles" ../
                            nmake
                        '''
                    }
                }
                stage('Windows/MSVC2017') {
                    agent {
                        label 'windows && cmake && msvc2017'
                    }
                    steps {
                        bat '''
                            set VSCMD_START_DIR=%CD%
                            call "%MSVC2017_BUILD_TOOLS%" x64 %WIN10_SDK_VER%
                            set PATH=%PATH%;%MINGW64%;
                            rmdir /Q /S build
                            mkdir build
                            cd build
                            call cmake -G "NMake Makefiles" ../
                            nmake

                        '''
                    }
                }
            }
        }
    }
}