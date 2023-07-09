# tlock

### Locking with timeouts.

tlock is handling "tlocks", advisory locks with timeouts.

They are implemented as simple directories that are created and deleted in the lock directory.

A distant predecessor was written many years ago as a kludge to make locking work properly on a Windows server. But it turned out to be very handy to have tlocks in the filesystem, giving you an at-a-glance overview of them. And giving the non-scripting sysadmins easy access to view and manipulate tlocks.

## Synopsis

    # taking a tlock for 5 minutes
    token=$(tlock take 'logwork' 300 || exit 1)

    move_old_index

    # hand over to that other script
    /usr/local/logrotate/logrotate $token

    -----------------------------------------------------------

    # checking lock is alive
    token=$1
    tlock alive 'logwork' $token || exit 1

    # Make time for the fancy rotation task.
    tlock renew 'logwork' 600

    do_fancy_log_rotation 547
    /usr/local/cleaning/clean-up-logs.sh $token

    # releasing the lock
    tlock release 'logwork' $token

## Configuration

There are a number of ways tlock parameters can be set, The prioritized list is:

1. Directly on the command line with options "-d", "-m" and "-p".

1. Environment variables "tlock_dir", "tlock_marker" and "tlock_patience".

1. Configuration file given by the environment variable "tlock_conf".

1. Configuration file "/etc/tlock.conf".

1. Default configuration.

## In the file system

Each tlock is a subdirectory of the lock directory. Their names are "$marker.$label". The default value for $marker is "tlock".

Each of the tlock directories has a sub directory named "d". The mtimes of these two directories saves the token and the timeout.
There also are some very shortlived directories named "$marker_.$label". They are per label master locks. They help making changes to the normal locks atomic.

## Command line

tlock &lbrack;-&lt;option&gt; &lbrack;parameter&rbrack;&rbrack; &lt;command&gt; &lbrack;parameter ...&rbrack;

## Options

-d &lt;d&gt;  Set the lock directory to &lt;d&gt;.

-h      Show help text.

-m &lt;m&gt;  Set marker to &lt;m&gt;.

-p &lt;p&gt;  Set patience to &lt;p&gt;.

-V      Show the version.

## Commands

**tlock take &lt;label&gt; &lt;timeout&gt; &lbrack;&lt;patience&gt;&rbrack;**

Takes the specified tlock if possible. Returns the token value.

**tlock renew &lt;label&gt; &lt;token&gt; &lt;timeout&gt;**

Renews the tlock.

**tlock release &lt;label&gt; &lt;token&gt;**

Releases the tlock.

**tlock alive &lt;label&gt; &lt;token&gt;**

Returns true if the specified tlock is still alive.

**tlock taken &lt;label&gt;**

Returns true if any tlock with the given label, is alive.

**tlock expiry &lt;label&gt;**

Returns the time when the tlock with the given label will expire.

**tlock zing**

Cleans up the lock directory.

## Parameters

**dir**

The directory containing the tlocks.

**marker**

The common prefix of the directory names used for tlocks.

Prefixes can be any non-empty string consisting of letters a-z or A-Z, digits 0-9, dashes "-" and underscores "_" (PCRE: [a-zA-Z0-9\-\_]+). First character has to be a letter, and last character a letter or digit.

**patience**

Patience is the time a method will try to take or change a tlock, before it gives up. For example when tlock_take tries to take a tlock that is already taken, it is the number of seconds it should wait for that tlock to be released before giving up.

Default patience value is 2.5 seconds.,

## One tlock, multiple scripts

The point of having tokens is to be able to hand over locks between scripts in a secure way. These scripts can be written in different languages. But they have to use the same dir and marker settings.

If you are using Perl there is a module available. You can read more here: [https://github.com/spragl/Tlock/blob/main/PERL.md](https://github.com/spragl/Tlock/blob/main/PERL.md)

## License & copyright

(c) 2022-2023 Bjoern Hee

Licensed under the Apache License, version 2.0

https://www.apache.org/licenses/LICENSE-2.0.txt
