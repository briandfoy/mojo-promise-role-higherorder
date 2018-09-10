package Mojo::Promise::Role::None;
use Mojo::Base '-role';

use strict;

use subs qw();
use vars qw($VERSION);

$VERSION = '0.001_01';

=encoding utf8

=head1 NAME

Mojo::Promise::Role::Any - Fulfill when all of the promises are rejected

=head1 SYNOPSIS

	use Mojo::Promise;

	my $none_promise = Mojo::Promise
		->with_roles( '+None' )
		->none( @promises );

=head1 DESCRIPTION

Make a new promise that fulfills when all promises are rejected, and
rejects otherwise.

=over 4

=item none( @promises )

Takes a lists of promises (or thenables) and returns another promise
that fulfills when all of the promises are rejected.

If none of the promises reject, the none promise rejects.

If you pass no promises, the none promise fulfills.

=cut

sub none {
	my( $self, @promises ) = @_;
	my $none = $self->new;

	$_->then( sub { $none->reject( @_ ) } ) foreach @promises;

	return @promises ? $none : $none->resolve;
	}

=back

=head1 SEE ALSO

L<Mojolicious>, L<Mojo::Promise>, L<Role::Tiny>

=head1 SOURCE AVAILABILITY

This source is in Github:

	http://github.com/briandfoy/mojo-promise-role-any/

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2018, brian d foy, All Rights Reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

1;
