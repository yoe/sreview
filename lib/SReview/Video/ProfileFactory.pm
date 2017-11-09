package SReview::Video::Profile::Base;

use Moose;

extends 'SReview::Video';

has '+reference' => (
	required => 1,
);

has 'exten' => (
	lazy => 1,
	is => 'ro',
	default => 'IEK -- extension not defined',
);

package SReview::Video::Profile::vp9;

use Moose;

extends 'SReview::Video::Profile::Base';

has '+exten' => (
	default => 'vp9.webm'
);

my %rates_30 = (
	240 => 150,
	360 => 276,
	480 => 750,
	720 => 1024,
	1080 => 1800,
	1440 => 6000,
	2160 => 12000
);

my %rates_50 = (
	240 => 150,
	360 => 276,
	480 => 750,
	720 => 1800,
	1080 => 3000,
	1440 => 9000,
	2160 => 18000
);

my %quals = (
	240 => 37,
	360 => 36,
	480 => 33,
	720 => 32,
	1080 => 31,
	1440 => 24,
	2160 => 15,
);

sub _probe_videobitrate {
	my $self = shift;
	if(eval($self->video_framerate) > 30) {
		return $rates_50{$self->video_height};
	} else {
		return $rates_30{$self->video_height};
	}
}

sub _probe_audiobitrate {
	return "128k";
}

sub _probe_quality {
	my $self = shift;
	return $quals{$self->video_height};
}

sub speed {
	my $self = shift;
	if($self->reference->has_pass) {
		if($self->reference->pass == 1 || $self->video_height < 720) {
			return 4;
		}
		return 2;
	}
}

sub _probe_videocodec {
	return "libvpx-vp9";
}

sub _probe_audiocodec {
	return "libopus";
}

no Moose;

package SReview::Video::Profile::vp8;

use Moose;

extends 'SReview::Video::Profile::Base';

has '+exten' => (
	default => 'vp8.webm',
);

sub _probe_videocodec {
	return "libvpx";
}

sub _probe_audiocodec {
	return "libvorbis";
}

sub _probe_audiobitrate {
	return undef;
}

no Moose;

package SReview::Video::Profile::vp8_lq;

use Moose;

extends 'SReview::Video::Profile::vp8';

has '+exten' => (
	default => 'lq.webm',
);

sub _probe_height {
	my $self = shift;
	return int($self->reference->video_height / 8);
}

sub _probe_width {
	my $self = shift;
	return int($self->reference->video_width / 8);
}

sub _probe_videosize {
	my $self = shift;
	return $self->video_width . "x" . $self->video_height;
}

no Moose;

package SReview::Video::ProfileFactory;

sub create {
	my $class = shift;
	my $profile = shift;
	my $ref = shift;

	eval "require SReview::Video::Profile::$profile;";

	return "SReview::Video::Profile::$profile"->new(url => '', reference => $ref);
}

1;
