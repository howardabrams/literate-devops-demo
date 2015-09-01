"""Deals with reporting NRPE checks in Nagios."""

import sys

# Variables can be be imported and used in other scripts, as in:
#
#    from reporter import Reporter, OK, WARNING, CRITICAL
#
# While this code results in a slightly longer import line, the call
# to 'done' is shorter and more clear.

OK = "OK"
NORMAL = OK
WARNING = "WARNING"
CRITICAL = "CRITICAL"
UNKNOWN = "UNKNOWN"

class Reporter(object):
    """
    Deals with Nagios reporting. Typical example:

    >>> from reporter import Reporter
    >>> r = Reporter()

    After the conditions have been met, call one of the 'done'
    methods:

    >>> r.ok("Mission accomplished.")

    Or better yet, use the 'warning' method:

    >>> r.warning("foo bar {1} and {0}", [42, "baz"])

    Which will return the following:

    WARNING: foo bar baz and 42
    """

    def __init__(self):
        self.data = {}

    code = {OK: 0, WARNING: 1, CRITICAL: 2, UNKNOWN: 3}

    def add(self, key, value):
        "Add a metric to the message that will be returned."
        self.data[key] = value

    def ok(self, msg, values=None):
        """Finishes execute with a Nagios OK message. See `done` for details."""
        self.done(OK, msg, values)

    def warning(self, msg, values=None):
        """Finishes execute with a Nagios WARNING message. See `done` for details."""
        self.done(WARNING, msg, values)

    def critical(self, msg, values=None):
        """Finishes execute with a Nagios CRITICAL message. See `done` for details."""
        self.done(CRITICAL, msg, values)

    def unknown(self, msg, values=None):
        """Finishes execute with a Nagios UNKNOWN message. See `done` for details."""
        self.done(UNKNOWN, msg, values)

    def done(self, severity, msg, values=None):
        """
        Outputs according to Nagios expectations and exits with one of the
        codes below.

        The `msg' can either be a simple string message, or can be a
        string format message, in which case, the 'values' parameters
        will be substituted into the message.

        Exit codes are based on the `severity' specified:
        0 - the check passed successfully
        1 - the check generated a warning
        2 - the check generated an alert
        3 - unknown
        """

        # If we are given a list of values to substitute, we will
        # perform the string formatting at this time, otherwise, we
        # just assume that the 'msg' is complete.
        if values != None and len(values) > 0:
            msg = apply(msg.format, values)

        if len(self.data.keys()) > 0:
            metrics = "; ".join(["%s=%s" % (k, self.data[k]) for k in self.data.keys()])
            full_line = "{0}: {1} | {2}".format(severity, msg, metrics)
        else:
            full_line = "{0}: {1}".format(severity, msg)

        # Our build of Nagios can only handle up to 1024 chars in
        # check output.  Limit the output to less than 1024 here so it
        # doesn't cause any unnecessary alerts.
        if len(full_line) > 1024:
            print full_line[:1023]
        else:
            print full_line

        sys.exit(self.code[severity])
