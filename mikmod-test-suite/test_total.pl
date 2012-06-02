#!/usr/bin/perl

use strict;
use warnings;

use IO::All;
use FindBin;

my $base = $FindBin::Bin;

my $mods_dir = io("$base/mods");
$mods_dir->mkpath;
io("$base/good-wavs")->mkpath;
io("$base/good-sha256sums")->mkpath;
io("$base/received")->mkpath;

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

foreach my $mod (@module_files)
{
    my $get_mod = sub { $mods_dir->catfile($mod); };
    my $mod_in_dir = $get_mod->();
    if (! $mod_in_dir->exists)
    {
        io("/mnt/smb/music/Music/mp3s/Mods/$mod") > $mod_in_dir;
        $mod_in_dir = $get_mod->();
    }


}
