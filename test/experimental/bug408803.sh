. inc/common.sh

init
run_mysqld --interactive_timeout=1 --wait_timeout=1
load_dbase_schema sakila
load_dbase_data sakila

# Take backup
mkdir -p $topdir/backup
run_cmd ${IB_BIN} --user=root --socket=$mysql_socket $topdir/backup > $OUTFILE 2>&1
backup_dir=`grep "innobackupex: Backup created in directory" $OUTFILE | awk -F\' '{ print $2}'`
vlog "Backup dir in $backup_dir"

stop_mysqld
# Remove datadir
rm -r $mysql_datadir
# Restore sakila
vlog "Applying log"
echo "###########" >> $OUTFILE
echo "# PREPARE #" >> $OUTFILE
echo "###########" >> $OUTFILE
run_cmd ${IB_BIN} --apply-log $backup_dir >> $OUTFILE 2>&1

vlog "Restoring MySQL datadir"
mkdir -p $mysql_datadir
echo "###########" >> $OUTFILE
echo "# RESTORE #" >> $OUTFILE
echo "###########" >> $OUTFILE
run_cmd ${IB_BIN} --copy-back $full_backup_dir >> $OUTFILE 2>&1

run_mysqld
# Check sakila
${MYSQL} ${MYSQL_ARGS} -e "SELECT count(*) from actor" sakila
stop_mysqld
clean
