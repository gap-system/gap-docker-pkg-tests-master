# WHY DOES A PACKAGE TEST MIGHT FAIL?

1. Check log files for each of the three scenarios:
- when GAP is started with only required packages; 
- with all packages loaded; 
- and with default set of packages. 

2. If any of the three test logs contain diffs (marked as
`########> Diff`), the test is reported as failed.

3. If the package is not loadable because its build fails, 
check the latest build log for the Docker container: 
https://hub.docker.com/r/gapsystem/gap-docker-master/builds/

4. If you need to investigate the problem in the same 
environment that is used for these tests, you may download 
and run the Docker container following instructions given at
https://hub.docker.com/r/gapsystem/gap-docker-master/

5. If all three logs looks good to you, it could be that it 
is still not possible to detect the status of your test, for
example, if you are still using `ReadTest`. Please consider
using `TestDirectory()` instead. For more information, see
https://github.com/gap-system/gap/wiki/Status-of-standard-tests-in-GAP-packages

