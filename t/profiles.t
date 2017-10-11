#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More;
use_ok('SReview::Video');
#use_ok('SReview::VideoPipe');
use_ok('SReview::Video::ProfileFactory');

my $input = SReview::Video->new(url => 't/testvids/7184709189_sd.mp4');
ok(defined($input), "Could create the input video");
ok($input->video_codec eq "h264", "video codec of input file is what we expected");

my $profile = SReview::Video::ProfileFactory->create("vp9", $input);
ok(defined($profile), "Could create a VP9 video profile based on the input video");
ok($profile->video_codec ne $input->video_codec, "video codec of profiled file is not the same as the input video codec");

my $output = SReview::Video->new(url => "t/testvids/foo.webm", reference => $profile);
ok(defined($output), "Could create an output video from the profile");
ok($output->video_height == $input->video_height, "The VP9 video has the same height as the input video");

$profile = SReview::Video::ProfileFactory->create('vp8_lq', $input);
ok(defined($profile), "Could create a VP8 LQ profile based on the input video");
$output = SReview::Video->new(url => "t/testvids/foo.webm", reference => $profile);
ok(defined($output), "Could create an output video from the LQ profile");
ok($output->video_height < $input->video_height, "The LQ profile creates smaller videos");
ok($output->video_codec eq "libvpx", "A VP8 video has the correct video codec");

done_testing();
