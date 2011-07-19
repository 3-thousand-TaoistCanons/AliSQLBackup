=====================================================
 Sending Backups to Remote Hosts with |innobackupex|
=====================================================

Besides of using the :option:`--stream` for sending the backup to another host via piping (see :doc:`streaming_backups_innobackupex`), |innobackupex| can do it directly with the :option:`--remote-host` ::

  $ innobackupex --remote-host=REMOTEUSER@REMOTEHOST /path/IN/REMOTE/HOST/to/backup/

|innobackupex| will test the connection to ``REMOTEHOST`` via :command:`ssh` and create the backup directories needed as the ``REMOTEUSER`` you specified.

.. warning:: The path you provide for storing the backup will be created at ``REMOTEHOST``, not at the local host.

Then all the log files will be written to a temporary file (you can choose where to store this file with the :option:`--tmpdir` option) and will be copied via :command:`scp`. The options for :command:`scp` can be specified with :option:`--options-scp` (``-Cp -c arcfour`` by default), for example::

  $ innobackupex --remote-host=REMOTEUSER@REMOTEHOST /path/IN/REMOTE/HOST/to/backup/ \
     --tmpdir=/tmp --options-scp="-Cp -c arcfour"


