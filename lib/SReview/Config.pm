use strict;
use warnings;

package SReview::Config;

use Data::Dumper;
use Carp;

sub new {
	my $self = {defs => {}};
	my $class = shift;

	bless $self, $class;

	my $cfile = shift;

	if (! -f $cfile) {
		carp "Warning: could not find configuration file $cfile, falling back to defaults";
	} else {
		package SReview::Config::_private;
		use Carp;
		my $rc = do($cfile);
		if($@) {
			croak "could not compile config file $cfile: $@";
		} elsif(!defined($rc)) {
			carp "could not read config file $cfile. Falling back to defaults.";
		} elsif(!$rc) {
			croak "could not process config file $cfile";
		}
	}
	return $self;
};

sub define {
	my $self = shift;
	my $name = shift;
	my $doc = shift;
	my $default = shift;
	if(exists($self->{fixed})) {
		croak "Tried to define a new value after a value has already been requested. This is not allowed!";
	}
	$self->{defs}{$name}{doc} = $doc;
	$self->{defs}{$name}{default} = $default;
};

sub get {
	my $self = shift;
	my $name = shift;
	if(!exists($self->{defs}{$name})) {
		die "e: definition for config file item $name does not exist!";
	}
	$self->{fixed} = 1;
	if(exists($SReview::Config::_private::{$name})) {
		return ${$SReview::Config::_private::{$name}};
	} else {
		if(defined($ENV{'SREVIEW_VERBOSE'}) && $ENV{'SREVIEW_VERBOSE'} gt 0) {
			print "No configuration value found for $name, using defaults\n";
		}
		return $self->{defs}{$name}{default};
	}
};

sub dump {
	my $self = shift;
	foreach my $conf(keys %{$self->{defs}}) {
		print "# " . $self->{defs}{$conf}{doc} . "\n";
		print "#" . Data::Dumper->Dump([$self->{defs}{$conf}{default}], [$conf]) . "\n";
	}
	print "# Do not remove this, perl needs it\n1;\n";
};

1;