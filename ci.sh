#!/usr/bin/env bash

# running GAP tests suite

set -e

SRCDIR=${SRCDIR:-$PWD}

echo SRCDIR   : $SRCDIR
echo PKG_NAME : $PKG_NAME

cd ${GAP_HOME}

make testpackage PKGNAME=$PKG_NAME

echo ""
echo "######################################################################"
echo "#"
echo "# TEST WITHOUT PACKAGES, EXCEPT REQUIRED BY GAP (using -A option)"
echo "#"
echo "######################################################################"
echo ""
cat dev/log/testpackage1*.${PKG_NAME}

echo ""
echo "######################################################################"
echo "#"
echo "# TEST WITH ALL PACKAGES LOADED (using LoadAllPackages() command)"
echo "#"
echo "######################################################################"
echo ""
cat dev/log/testpackage2*.${PKG_NAME}

echo ""
echo "######################################################################"
echo "#"
echo "# TEST WITH DEFAULT PACKAGES, LOADED AT GAP STARTUP"
echo "#"
echo "######################################################################"
echo ""
cat dev/log/testpackageA*.${PKG_NAME}

for TESTCASE in A 1 2
do
    export TESTRESULT=`cat dev/log/testpackage${TESTCASE}*.$PKG_NAME | grep -c "#I  No errors detected while testing"`
    if [ $TESTRESULT = '1' ]
    then
        # info message is there - this is a clear PASS
        export PASS$TESTCASE=PASS
    else
        export NUMFAILS=`cat dev/log/testpackage${TESTCASE}*.$PKG_NAME | grep -c "########> Diff"`
        if [ $NUMFAILS = '0' ]
        then
            # zero diffs, but no info message - what could that mean?
            export TESTCOMPLETED=`cat dev/log/testpackage${TESTCASE}*.$PKG_NAME | grep -c "#I  RunPackageTests"`
            if [ $TESTCOMPLETED = '2' ]
            then
                # still there are two "RunPackageTests" (one at the beginning of the test, one at the end)
                # This means that at least the test did not crash
                export PASS$TESTCASE="UNCLEAR"
            elif [ $TESTCOMPLETED = '1' ]
            # only one "RunPackageTests": either a crash or LoadPackage returned 'fail'
            then
                if [ `cat dev/log/testpackage${TESTCASE}*.$PKG_NAME | grep "#I  RunPackageTests" | grep -c "not loadable"` = '1' ]
                then
                    # if LoadPackage returned fail, this will be clearly indicated in the log
                    export PASS$TESTCASE="NOT LOADED"
                else
                    # otherwise, log has initial RunPackageTests, package was loaded and then crashed
                    export PASS$TESTCASE="CRASH"
                fi
            else
                # The log does not contain "RunPackageTests" at all
                export PASS$TESTCASE="NOT STARTED"
            fi
        else
            # one of more diffs - this is a clear FAIL
            export PASS$TESTCASE="${NUMFAILS} DIFFS"
        fi
    fi
done

echo ""
echo "######################################################################"
echo "#"
echo "# TESTS SUMMARY"
echo "#"
echo "######################################################################"
echo ""
echo 'Package name                                         : ' $PKG_NAME 
echo 'With no packages loaded (GAP started with -r option) : ' $PASS1
echo 'With all packages loaded with LoadAllPackages()      : ' $PASS2
echo 'With default packages loaded at GAP startup          : ' $PASSA
echo ""

if [ "${PASS1}" != 'PASS' ] || [ "${PASS2}" != 'PASS' ] || [ "${PASSA}" != 'PASS' ]
then
  echo "######################################################################\n"
  echo ""
  cat /home/gap/travis/HELP.md
  echo "######################################################################"
  echo ""
  exit 1
fi