source $SRCDIR/libtest.sh

test_non_absolute_disk_name() {
  local devs dev
  local test_status=1
  local testname=`basename "$0"`
  local vg_name="dss-test-foo"
  local infile=${WORKDIR}/container-storage-setup
  local outfile=${WORKDIR}/container-storage

  # Remove prefix /dev/ from disk names to test if non-absolute disk
  # names work.
  for dev in $TEST_DEVS; do
    dev=${dev##/dev/}
    devs="$devs $dev"
  done

  # Error out if any pre-existing volume group vg named dss-test-foo
  if vg_exists "$vg_name"; then
    echo "ERROR: $testname: Volume group $vg_name already exists." >> $LOGS
    return $test_status
  fi

  cat << EOF > $infile
DEVS="$devs"
VG=$vg_name
CONTAINER_THINPOOL=container-thinpool
EOF

  # Run docker-storage-setup
  $DSSBIN $infile $outfile >> $LOGS 2>&1

  # Test failed.
  if [ $? -ne 0 ]; then
    echo "ERROR: $testname: $DSSBIN failed." >> $LOGS
    cleanup $vg_name "$TEST_DEVS" "$infile" "$outfile"
    return $test_status
  fi

  # Make sure volume group $VG got created.
  if vg_exists "$vg_name"; then
    test_status=0
  else
    echo "ERROR: $testname: $DSSBIN $infile $outfile failed. $vg_name was not created." >> $LOGS
  fi

  cleanup $vg_name "$TEST_DEVS" "$infile" "$outfile"
  return $test_status
}

# Make sure non-absolute disk names are supported. Ex. sdb.
test_non_absolute_disk_name
