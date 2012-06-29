#!/usr/bin/perl

use strict;
use warnings;

use IO::All;
use FindBin;
use List::Util qw(first);
use Getopt::Long;

my $start_re;

GetOptions(
    'start=s' => \$start_re,
) or die "Wrong options";

# Seed for the random number.
local $ENV{'MIKMOD_SRAND_CONSTANT'} = "2400";

my $base = $FindBin::Bin;
chdir($base);

my $mods_dir = io("./mods");
$mods_dir->mkpath;
my $good_dir = io("./good-wavs");
$good_dir->mkpath;
my $sums_dir = io("./good-sha256sums");
$sums_dir->mkpath;
my $received_dir = io("./received");
$received_dir->mkpath;

my @module_files = (qw(
    80472-kingdom.xm
    For_XP_sounds_attempt_Extended.it
    Ranger_Song.s3m
    axel.mod
    canonind.it
    crysdrag.s3m
    dontworr.mod
    fb-echo.it
    flower-rock.mod
    focus.mod
    funkjung.mod
    galactic.mod
    inside.s3m
    junglebeats.it
    monkeyisland2.xm
    ohhahh2.it
    popcorn99.xm
    short.s3m
    sll5.mod
    snowy.it
    spx-shuttledeparture.it
    tropical.xm
    tutim.mod
    vampire.mod
    yonqatan.mod
));

my @lines = `mikmod -n`;

my $re = qr/^\s*(\d+)\s*Wav disk writer/;

my $line = first { $_ =~ /$re/ } @lines;

if (!defined($line))
{
    die "Your mikmod does not support the Wav disk writer - check `mikmod -n`!";
}

my ($driver_id) = $line =~ /$re/;

foreach my $mod (grep { (defined($start_re) ? /$start_re/ : 1) .. 1 } @module_files)
{
    my $get_mod = sub { $mods_dir->catfile($mod); };
    my $mod_in_dir = $get_mod->();
    if (! $mod_in_dir->exists)
    {
        io("/mnt/smb/music/Music/mp3s/Mods/$mod") > $mod_in_dir;
        $mod_in_dir = $get_mod->();
    }

    my $got_wav = io($received_dir)->catfile("$mod.wav");
    system("mikmod", "-d", "$driver_id,file=$got_wav", $mod_in_dir);

    my $good_wav = io($good_dir)->catfile("$mod.wav");
    if (! $good_wav->exists())
    {
        $got_wav > $good_wav;
        my $out = `sha256sum $good_wav`;
        if (my ($checksum) = ($out =~ m/\A([\da-f]+)\s/))
        {
            $checksum .= "\n";
            my $sum_fn = $sums_dir->catfile("$mod.sha256sum");

            if (! $sum_fn->exists() )
            {
                $sum_fn->print($checksum);
            }
            else
            {
                if ($sum_fn->slurp() ne $checksum)
                {
                    die "Different checksums on $mod";
                }
            }
        }
        else
        {
            die "sha256sum returned error on $good_wav.";
        }
    }
    else
    {
        if (system("cmp", "-s", $good_wav, $got_wav))
        {
            die "Failure in comparing output of $mod - $good_wav vs. $got_wav";
        }
    }
}

=head1 COPYRIGHT & LICENSE

Copyright 2012 by Shlomi Fish

This program is distributed under the MIT (X11) License:
L<http://www.opensource.org/licenses/mit-license.php>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

=cut
