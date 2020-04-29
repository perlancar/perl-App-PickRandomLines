package App::PickRandomLines;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;

our %SPEC;

$SPEC{pick_random_lines} = {
    v => 1.1,
    summary => 'Pick one or more random lines from input',
    description => <<'_',

TODO:
* option to allow or disallow duplicates

_
    args => {
        files => {
            schema => ['array*', of=>'filename*'],
            'x.name.is_plural' => 1,
            pos => 0,
            greedy => 1,
            description => <<'_',

If none is specified, will get input from stdin.

_
        },
        algorithm => {
            schema => ['str*', in=>[qw/scan seek/]],
            default => 'scan',
            description => <<'_',

`scan` is the algorithm described in the `perlfaq` manual (`perldoc -q "random
line"). This algorithm scans the whole input once and picks one or more lines
randomly from it.

`seek` is the algorithm employed by the Perl module `File::RandomLine`. It works
by seeking a file randomly and finding the next line (repeated `n` number of
times). This algorithm is faster when the input is very large as it avoids
having to scan the whole input. But it requires that the input is seekable (a
single file, stdin is not supported and currently multiple files are not
supported as well). *Might produce duplicate lines*.

_
        },
        num_lines => {
            schema => ['int*', min=>1],
            default => 1,
            cmdline_aliases => {n=>{}},
            description => <<'_',

If input contains less lines than the requested number of lines, then will only
return as many lines as the input contains.

_
        },
    },
    links => [
        {url=>'pm:Data::Unixish::pick'},
    ],
};
sub pick_random_lines {
    my %args = @_;

    # XXX schema
    my $n = $args{num_lines} // 1;
    $n > 0 or return [400, "Please specify a positive number of lines"];
    my $files = $args{files} // [];
    my $algo = $args{algorithm} // 'scan';
    $algo = 'scan' if !@$files || @$files > 1;

    my @lines;
    if ($algo eq 'scan') {
        require File::Random::Pick;
        my $path;
        if (!@$files) {
            $path = \*STDIN;
        } elsif (@$files > 1) {
            $path = \*ARGV;
        } else {
            $path = $files->[0];
        }
        @lines = File::Random::Pick::random_line($path, $n);
    } else {
        require File::RandomLine;
        my $rl = File::RandomLine->new($files->[0]);
        for (1..$n) { push @lines, $rl->next }
    }
    chomp @lines;
    [200, "OK", \@lines];
}

1;
# ABSTRACT:

=head1 SYNOPSIS

See L<pick-random-lines>.

=cut
