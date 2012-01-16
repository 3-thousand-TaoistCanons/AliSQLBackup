##########################################################################
# Bug #891496: tar4ibd fails on datafiles generated on 5.0               #
##########################################################################

. inc/common.sh

init

innodb_data_file_path="ibdata1:3M;ibdata2:10M:autoextend"

cat >> $topdir/my.cnf <<EOF
innodb_data_file_path=$innodb_data_file_path
EOF

MYSQLD_ARGS="$MYSQLD_ARGS --innodb_data_file_path=$innodb_data_file_path"

run_mysqld
load_dbase_schema sakila
load_dbase_data sakila

# Take backup
mkdir -p $topdir/backup
innobackupex --stream=tar $topdir/backup > $topdir/backup/out.tar

stop_mysqld
# Remove datadir
rm -r $mysql_datadir
# Restore sakila
vlog "Applying log"
backup_dir=$topdir/backup
cd $backup_dir
$TAR -ixvf out.tar
cd - >/dev/null 2>&1 
vlog "###########"
vlog "# PREPARE #"
vlog "###########"
innobackupex --apply-log $backup_dir
vlog "Restoring MySQL datadir"
mkdir -p $mysql_datadir
vlog "###########"
vlog "# RESTORE #"
vlog "###########"
innobackupex  --copy-back $backup_dir

run_mysqld
# Check sakila
run_cmd ${MYSQL} ${MYSQL_ARGS} -e "SELECT count(*) from actor" sakila
