# -*- perl -*-
#
# Text::Smart::Plugin by Daniel Berrange <dan@berrange.com>
#
# Copyright (C) 2004 Daniel P. Berrange <dan@berrange.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# $Id: Plugin.pm,v 1.2 2004/05/13 10:42:37 dan Exp $

=pod

=head1 NAME

  Text::Smart::Plugin - Template Toolkit plugin for Text::Smart

=head1 SYNOPSIS

    my $tt = new Template({
	PLUGINS => {
	    'smarttext' => 'Text::Smart::Plugin'
	    }
    });

     [% USE smarttext(type => 'HTML') %]
     [% FILTER smarttext %]

     ... some smart text markup ...

     [% END %]

=over 4

=cut

package Text::Smart::Plugin;

use base qw(Template::Plugin);
use vars qw($VERSION);

use Text::Smart::HTML;
use Carp qw(confess);

$VERSION = "1.0.0";

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $context = shift;
    my $options = shift;

    my $filter_factory;
    my $self;
    
    if ($options) {
	# create a closure to generate filters with additional options
	$filter_factory = sub {
	    my $context = shift;
	    my $filtopt = ref $_[-1] eq 'HASH' ? pop : { };
	    @$filtopt{ keys %$options } = values %$options;
	    return sub {
		tt_smarttext(@_, $filtopt);
	    };
	};

	# and a closure to represent the plugin
	$plugin = sub {
	    my $plugopt = ref $_[-1] eq 'HASH' ? pop : { };
	    @$plugopt{ keys %$options } = values %$options;
	    tt_smarttext(@_, $plugopt);
	};
    }
    else {
	# simple filter factory closure (no legacy options from constructor)
	$filter_factory = sub {
	    my $context = shift;
	    my $filtopt = ref $_[-1] eq 'HASH' ? pop : { };
	    return sub {
		tt_smarttext(@_, $filtopt);
	    };
	};

	# plugin without options can be static
	$plugin = \&tt_smarttext;
    }

    # now define the filter and return the plugin
    $context->define_filter('smarttext', [ $filter_factory => 1 ]);
    return $plugin;
}

sub tt_smarttext {
    my $options = ref $_[-1] eq 'HASH' ? pop : { };
    my $type = defined $options->{type} ? $options->{type} : "HTML";
    if ($type eq 'HTML') {
	my $proc = Text::Smart::HTML->new();

	return $proc->process(join('', @_));
    } else {
	confess "Unknown type $type";
    }
}

1 # So that the require or use succeeds.

__END__

=back 4

=head1 AUTHORS

Daniel Berrange <dan@berrange.com>

=head1 COPYRIGHT

Copyright (C) 2004 Daniel P. Berrange <dan@berrange.com>

=head1 SEE ALSO

L<perl(1)>, L<Text::Smart(1)>, L<Template(1)>

=cut
                                                                                                         
