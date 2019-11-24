#!/usr/bin/perl
# Author:  Saúl Blanco Tejero (@elGolpista)
# License: GPL-3.0-only

use strict;

use JSON;
use File::Path;
use MIME::Base64;


my @image_extensions = (
    'png', 'jpg',
    'svg', 'gif',
);

my @video_extensions = (
    'mp4', 'flv', 'mkv',
    'avi', 'wmv', 'm4v',
    'mov', 'mpg',
);

my @requested_extensions = ();


print <<MENU;
==== OPTIONS ====
 1 · ALL MEDIA
 2 · ONLY IMAGES
 3 · ONLY VIDEOS
 4 · OTHER\n
MENU

print "Select an option: "; my $op = <STDIN>;

if ($op == 1) {
    push(@requested_extensions, @image_extensions);
    push(@requested_extensions, @video_extensions);
}
elsif ($op == 2) { push(@requested_extensions, @image_extensions); }
elsif ($op == 3) { push(@requested_extensions, @video_extensions); }
elsif ($op == 4) {
    print "\nType the extensions (delimited by ',' or ' ' or '|')\n";
    print "-> "; my $custom_extensions = <STDIN>;
    push(@requested_extensions, split(/[,|\s]+/, $custom_extensions));
}

# TODO: Refactor all code below
$/ = undef;
my $json = <>;
my $json_hash_ref = decode_json($json);
my @entries = @{$json_hash_ref->{log}->{entries}};

foreach my $entry ( @entries ) {

    # TODO: Refactor, (create a subroutine)
    # Check requested extension with regexy
    foreach my $extension ( @requested_extensions ) {

        my $resource_url = $entry->{request}->{url};

        if ($resource_url =~ /(?i)(\w+\.($extension))/i) {

            my $resource_name = $1;
	    my $is_media = grep(/$2/, (@image_extensions, @video_extensions));
            # Using the mime-type to build resource path
            my $resource_path = 'out/'.$entry->{response}->{content}->{mimeType};
            my $file_content = $entry->{response}->{content}->{text};

	    unless ( -d $resource_path ) { mkpath($resource_path); }

            $resource_path .= "/$resource_name";

	    open my $fh, '>', $resource_path or die "Cannot open file: $!";

	    if ( ! $is_media ) { binmode $fh, ':utf8'; }
	    else { $file_content = decode_base64($file_content); }
	    print $fh $file_content;

	    close $fh or die "Cannot close fh: $!";

	    last;
        }
    }
}
# print time - $^T, "\n";
