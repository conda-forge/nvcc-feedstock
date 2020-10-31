@echo on

:: Verify the symlink to the libcuda stub library exists.


:: Verify the activation scripts are in-place.


:: Try using the activation scripts.


:: Set some CFLAGS to make sure we're not causing side effects


:: Manually trigger the activation script


:: Check activation worked as expected, then deactivate


:: Make sure there's no side effects


:: Reactivate


:: Try building something
nvcc test.cu
