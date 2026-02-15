# UniProton RISC-V Application Development Skill

This skill helps users develop, compile, and run UniProton RISC-V applications in a Docker environment. It includes complete processes for environment configuration, compilation steps, and running verification.

## Description

Helps users develop, compile, and run UniProton RISC-V applications in a Docker environment. Includes complete processes for environment configuration, compilation steps, running validation, and troubleshooting. This skill should be used when users need to develop UniProton applications, configure development environments, compile or run UniProton applications.

## Environment Configuration

### Docker Environment Configuration Requirements

#### Docker Image
- Must use the specified Docker image: `swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/uniproton-ci-test:v003`
- This image comes pre-installed with the required toolchain and other dependencies

#### Directory Mounting
- When starting the Docker container, mount the host folder: `-v $(pwd)/UniProton:/home/jenkins/UniProton`
- Note: The mount path should be the UniProton directory rather than the entire project root directory
- This maps the host's source code to the container for compilation purposes

#### Permission Settings
- Recommended to run the container as root user to avoid permission issues:
  - `docker run -itd -u root -v $(pwd)/UniProton:/home/jenkins/UniProton ...`
- Or set appropriate user mapping to ensure the container user can access host directories
- When using root user to run the container, no additional host file permissions need to be set

#### Compilation Configuration
- Ensure the environment variable `RISCV_NATIVE` is empty or unset
- Since this is a cross-compilation process, native RISC-V compilation options should not be enabled

## Operation Process

### 1. Start Docker Environment
- Start Docker container: `docker run -itd -u root -v $(pwd)/UniProton:/home/jenkins/UniProton swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/uniproton-ci-test:v003`
  - `-itd`: Run container in interactive mode in the background
  - `-u root`: Run container as root user to avoid permission issues
  - `-v $(pwd)/UniProton:/home/jenkins/UniProton`: Mount the current host's UniProton directory to the container's /home/jenkins/UniProton path
  - `swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/uniproton-ci-test:v003`: Specified Docker image
  - `/bin/bash`: Start bash shell
- Enter the running container: `docker exec -u root -it <container_id> /bin/bash`
  - `<container_id>`: Container ID or name
  - `-u root`: Enter container as root user
- Verify file permissions are correctly set: `ls -ld *`
- To stop container: `docker stop <container_id>`
- To start a stopped container: `docker start <container_id>`
- To delete container: `docker rm <container_id>`

### 2. Create New Application
- This step is performed on the Host
- Enter app directory: `cd UniProton/demos/riscv64virt/apps/`
- Create new app directory: `mkdir <your_app_name>`
- Create main.c and CMakeLists.txt files in the new directory
- Refer to UniProton/demos/riscv64virt/apps/hello_world to create the app, but if console functionality is not needed, do not include it
- Copy console.h and console.c files from an existing app (such as hello_world) to the new app directory (only when console functionality is needed)

### 3. Configure New Application
- This step is performed on the Host
- Modify apps/CMakeLists.txt file, add new app branch:
  ```cmake
  elseif (APP STREQUAL "<your_app_name>")
      add_subdirectory(<your_app_name>)
  endif()
  ```
- Create CMakeLists.txt in the app directory, configure source files and library linking
- Modify build/build_app.sh file, add new app support:
  ```bash
  elif [[ $one_arg == "<your_app_name>" ]]; then
      export APP=<your_app_name>
  ```
- Ensure CMakeLists.txt creates an OBJECT library rather than EXECUTABLE

### 4. Compilation Process
- Important: The compilation process must be completed inside the Docker container
- Enter build directory: `cd UniProton/demos/riscv64virt/build/`
- Execute build script: `sh build_app.sh <your_app_name>`
- The build process performs the following main steps:
  - Generate prt_buildef.h configuration file
  - Use CMake for project configuration
  - Compile BSP (Board Support Package) components
  - Compile application code
  - Link to generate executable files
  - Generate ELF and binary format output files

### 5. Run and Verify
- This step is completed inside the Docker container
- Enter output directory: `cd UniProton/demos/riscv64virt/build/out/`
- Use QEMU emulator to run program:
  ```bash
  /opt/qemu/bin/qemu-system-riscv64 -bios none -M virt -m 512M -nographic -kernel <your_app_name>.elf -smp 1
  ```
- Observe program output to confirm successful execution

## Technical Details
- Architecture: RISC-V 64-bit
- Toolchain: riscv64-unknown-elf-gcc (GCC 13.2.0)
- Target Platform: RISC-V virt
- Memory Allocation: 512MB
- Core Count: 1
- Emulator: QEMU 8.2.0 (located at /opt/qemu/bin/)

## Common Application Templates

### Hello World Example
- App Name: hello_world
- Build Command: `sh build_app.sh hello_world`
- Expected output after running should contain: `hard driver init end!!!` and `start!!!!`

### Other Application Types
- Can replace `<your_app_name>` with other sample app names
- Common examples include: task_manage, sem_test, mutex_test, etc.

## Troubleshooting

### General Issues
- **Container permission issues**: Recommended to use -u root parameter when running container to avoid permission issues
- **Image tag issues**: Ensure using correct image tag (usually v003)
- **Mount path issues**: Ensure mounting UniProton directory rather than parent directory

### Compilation Errors
- **Missing header files**: Check if CMakeLists.txt include_directories contains necessary header file paths
- **Target conflicts**: Ensure CMakeLists.txt creates OBJECT library rather than EXECUTABLE
- **Syntax errors**: Check bash syntax in scripts like build_app.sh
- **Undefined functions**: Ensure required API headers are properly included

### Runtime Errors
- **QEMU path**: Confirm using full path `/opt/qemu/bin/qemu-system-riscv64`
- **ELF file existence**: Check if ELF file was generated correctly in out directory
- **Memory configuration**: Verify QEMU memory set to at least 512M

### Special Issues
- **CSR register access**: If using RISC-V CSR register access functions (like r_mhartid, etc.), ensure correct header files are included
- **Console functionality**: Copy console.h and console.c files from hello_world to get console functionality
- **Build script corruption**: If build_app.sh is corrupted, consider rewriting completely or restoring from backup

## Best Practices

### Development Workflow
1. Edit source code files on the host
2. Compile and test in the container
3. When running container as root user, no special handling of file permissions is needed
4. Files can be edited directly in the container (when running as root user, no permission issues will arise)

### Debugging Tips
- Use `docker exec -it <container_id> /bin/bash -c '<command>'` to execute a single command
- Check file permissions before compiling: `ls -la`
- Use `find` command to locate header file locations
- Check include path settings in CMakeLists.txt
- When encountering build or runtime issues, add necessary debug prints to identify the location and nature of the problem, infer and resolve issues based on actual output
- Utilize available debugging tools, such as QEMU's monitor feature, which can provide relevant information
