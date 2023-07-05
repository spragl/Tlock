# NAME

Sys::Tlock - Locking with timeouts.

# VERSION

1.02

# SYNOPSIS

    use Sys::Tlock dir => '/var/myscript/locks/' , qw(tlock_take $patience);

    print "tlock patience is ${patience}\n";

    # taking a tlock for 5 minutes
    tlock_take('logwork',300) || die 'Failed taking the tlock.';
    my $token = $_;

    move_old_index();

    # hand over to that other script
    exec( "/usr/local/logrotate/logrotate.pl" , $token );

    -----------------------------------------------------------

    use Sys::Tlock;
    # /etc/tlock.conf sets dir to "/var/myscript/locks/"

    # checking lock is alive
    my $t = $ARGV[0];
    die 'Tlock not taken.' if not tlock_alive('logwork',$t);

    # Make time for the fancy rotation task.
    tlock_renew('logwork',600);

    do_fancy_log_rotation(547);
    system( './clean-up.sh' , $t );

    # releasing the lock
    tlock_release('logwork',$t);

# DESCRIPTION

This module is handling tlocks, advisory locks with timeouts.

They are implemented as simple directories that are created and deleted in the lock directory.

A distant predecessor to this module was written many years ago as a kludge to make locking work properly on a Windows server. But it turned out to be very handy to have tlocks in the filesystem, giving you an at-a-glance overview of them. And giving the non-scripting sysadmins easy access to view and manipulate them.

The module is designed to allow separate programs to use the same tlocks between them. Even programs written in different languages. To do this safely, tlocks are paired with a lock token.

## CONFIGURATION

The configuration parameters are set using this process:

- 1. Directly in the use statement of your script, with keys "dir", "marker" and "patience".
- 2. Configuration file given by a "conf" key in the use statement of your script.
- 3. Environment variables "tlock\_dir", "tlock\_marker" and "tlock\_patience".
- 4. Configuration file given by the environment variable "tlock\_conf".
- 5. Configuration file "/etc/tlock.conf".
- 6. Default configuration.

On top of this, you can import the $dir, $marker and $patience variables and change them in your script. But that is a recipe for disaster, so know what you do, if you go that way.

Configuration files must start with a "tlock 0" line. Empty lines are allowed and so are comments starting with the # character. There are three directives:

`dir` For setting the lock directory. Write the full path.

`marker` For the marker (prefix) that all tlock directory names will get.

`patience` For the time that the take method will wait for a lock release.

    tlock 0
    # Example configuration file for tlock.
    dir      /var/loglocks/
    patience 7.5

## TOKENS

Safe use of tlocks involve tokens, which are just timestamps of when the lock was taken.

Without tokens, something like this could happen...

    script1 takes lockA
    script1 freezes
    lockA times out
    script2 takes lockA
    script1 resumes
    script1 releases lockA
    script3 takes lockA

Now both script2 and script3 "have" lockA!

## IN THE FILESYSTEM

Each tlock is a subdirectory of the lock directory. Their names are "${marker}.${label}". The default value for $marker is "tlock".

Each of the tlock directories has a sub directory named "d". The mtimes of these two directories saves the token and the timeout.
There also are some very shortlived directories named "${marker}\_.${label}". They are per label master locks. They help making changes to the normal locks atomic.

# FUNCTIONS AND VARIABLES

Loaded by default:
[tlock\_take](#tlock_take-label-timeout),
[tlock\_renew](#tlock_renew-label-token-timeout),
[tlock\_release](#tlock_release-label-token),
[tlock\_alive](#tlock_alive-label-token),
[tlock\_taken](#tlock_taken-label),
[tlock\_expiry](#tlock_expiry-label),
[tlock\_zing](#tlock_zing)

Loaded on demand:
[tlock\_tstart](#tlock_tstart-label),
[tlock\_release\_careless](#tlock_release_careless-label),
[tlock\_token](#tlock_token-label),
[$dir](#dir),
[$marker](#marker),
[$patience](#patience)

- tlock\_take( $label , $timeout )

    Take the tlock with the given label, and set its timeout. The call returns the associated token.

    Labels can be any non-empty string consisting of letters a-z or A-Z, digits 0-9, dashes "-", underscores "\_" and dots "." (PCRE: \[a-zA-Z0-9\\-\\\_\\.\]+)

    It is possible to set a per call special patience value, by adding it as a third variable, like this: tlock\_take( 'busylock' , $t , 600 )

    The token value is also assigned to the $\_ variable.

- tlock\_renew( $label , $token , $timeout )

    Reset the timeout of the tlock, so that it will time out $timeout seconds from the time that tlock\_renew is called.

- tlock\_release( $label , $token )

    Release the tlock.

- tlock\_alive( $label , $token )

    Returns true if the tlock is currently taken.

- tlock\_taken( $label )

    Returns true if a tlock with the given label is currently taken.

    The difference between tlock\_taken and tlock\_alive, is that alive can differentiate between different tlocks with the same label. Different tlocks with the same label can exist at different points in time.

- tlock\_expiry( $label )

    Returns the time when the current tlock with the given label will expire. It is given in epoch seconds.

- tlock\_zing()

    Cleans up locks in the lock directory. Takes care not to mess with any lock activity.

- tlock\_tstart( $label )

    Returns the time for the creation of the current tlock with the given label. It is given in epoch seconds. This function and the token function are identical.

    Only loaded on demand.

- tlock\_release\_careless( $label )

    Carelessly release any tlock with the given label, not caring about the token.

    Only loaded on demand.

- tlock\_token( $label )

    Returns the token for the current tlock with the given label.

    Only loaded on demand.

- $dir

    The directory containing the tlocks.

    Only loaded on demand.

- $marker

    The common prefix of the directory names used for tlocks.

    Prefixes can be any non-empty string consisting of letters a-z or A-Z, digits 0-9, dashes "-" and underscores "\_" (PCRE: \[a-zA-Z0-9\\-\\\_\]+). First character has to be a letter, and last character a letter or digit.

    Only loaded on demand.

- $patience

    Patience is the time a method will try to take or change a tlock, before it gives up. For example when tlock\_take tries to take a tlock that is already taken, it is the number of seconds it should wait for that tlock to be released before giving up.

    Dont confuse patience with timeout.

    Default patience value is 2.5 seconds.

    Only loaded on demand.

# DEPENDENCIES

File::Basename

Time::HiRes

# KNOWN ISSUES

The author dare not guarantee that the locking is waterproof. But if there are conditions that breaks it, they must be very special. At the least, experience has shown it to be waterproof in practice.

Not tested on Windows, ironically enough.

# SEE ALSO

flock

# LICENSE & COPYRIGHT

(c) 2022-2023 Bjoern Hee

Licensed under the Apache License, version 2.0

https://www.apache.org/licenses/LICENSE-2.0.txt
