=======================================
 Creating a Backup with |innobackupex|
=======================================

|innobackupex| is the tool that glues |xtrabackup| and |tar4ibd|, which are specific tools, plus adding functionality to provide a single interface to backup all the data in your database server.

To create a full backup, invoke the script with the options needed to connect to the server and only one argument: the path to the directory where the backup will be stored ::

  $ innobackupex --user=DBUSER --password=DBUSERPASS /path/to/BACKUP-DIR/

and check the last line of the output for a confirmation message:

.. code-block:: console

  innobackupex: Backup created in directory '/path/to/BACKUP-DIR/2011-12-25_00-00-09'
  innobackupex: MySQL binlog position: filename 'mysql-bin.000003', position 1946		
  111225 00:00:53  innobackupex: completed OK!

The backup will be stored within a time stamped directory created in the provided path, :file:`/path/to/BACKUP-DIR/2011-12-25_00-00-09` in this particular example.

Under the hood
==============

|innobackupex| called |xtrabackup| binary to backup all the data of |InnoDB| tables (see :doc:`../xtrabackup_bin/creating_a_backup` for details on this process) and copied all the table definitions in the database (:term:`.frm` files), data and files related to |MyISAM|, :term:`MERGE <.MRG>` (reference to other tables), :term:`CSV <.CSV>` and :term:`ARCHIVE <.ARM>` tables, along with :term:`triggers <.TRG>` and :term:`database configuration information <.opt>` to a time stamped directory created in the provided path. 

It will also create the following files for convenience on the created directory:

  * Information related to the backup and the server

    * :file:`xtrabackup_checkpoints`
       The type of the backup (e.g. full or incremental), its state (e.g. prepared) and the |LSN| range contained in it. This information is used for incremental backups.

    * :file:`xtrabackup_binlog_info`
       The binary log file used by the server and its position at the moment of the backup. Result of the :command:`SHOW MASTER STATUS`.

    * :file:`xtrabackup_binlog_pos_innodb`
       The binary log file and its current position for |InnoDB| or |XtraDB| tables.

    * :file:`xtrabackup_binary`
       The |xtrabackup| binary used in the process.

    * :file:`backup-my.cnf`
       This file contains information to start the mini instance of InnoDB during the  :option:`--apply-log`. This is NOT a backup of original :file:`my.cnf`.
    
    * :file:`xtrabackup_logfile` 
       Contains data needed for running the: :option:`--apply-log`. The bigger this file is the :option:`--apply-log` process will take longer to finish. 

  * Information related to the replication environment (if using the :option:`--slave-info` option):

    * :file:`xtrabackup_slave_info`
       The ``CHANGE MASTER`` statement needed for setting up a slave.

  * The output of :program:`mysqld` during the backup process:

    * :file:`mysql-stderr`

    * :file:`mysql-stdout`

Other options to consider
=========================

The :option:`--no-timestamp` option
-----------------------------------

This option tells |innobackupex| not to create a time stamped directory to store the backup::

  $ innobackupex --user=DBUSER --password=DBUSERPASS /path/to/BACKUP-DIR/ --no-timestamp

|innobackupex| will create the ``BACKUP-DIR`` subdirectory (or fail if exists) and store the backup inside of it.

The :option:`--defaults-file` option
------------------------------------

You can provide other configuration file to |innobackupex| with this option. The only limitation is that **it has to be the first option passed**::

  $ innobackupex --defaults-file=/tmp/other-my.cnf --user=DBUSER --password=DBUSERPASS /path/to/BACKUP-DIR/

