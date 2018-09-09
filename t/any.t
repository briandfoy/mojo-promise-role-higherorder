use v5.14;
use Mojo::Base -strict;

use feature qw(signatures);
no warnings qw(experimental::signatures);

BEGIN { $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll' }

use Test::More;
use Mojo::IOLoop;
use Mojo::Promise;

my $class  = 'Mojo::Promise::Role::Any';
my $target = 'Mojo::Promise';
my $method = 'any';

use_ok( $class );

subtest setup => sub {
	can_ok( $class, $method );

	can_ok( $target, 'with_roles' );

	my $promise = $target->with_roles( '+Any' );
	can_ok( $promise, $method );
	};

sub resolve_one ( $number, $position ) {
	my @promises = map {
		Mojo::Promise->new
		} 0 .. $number - 1;

	my $first = Mojo::Promise
		->with_roles('+Any')
		->any( @promises );

	my( @results, @errors );
	$first->then(
		sub { @results = @_ },
		sub { @errors  = @_ }
		);

	$promises[$position]->resolve( qw(Bender Leela) );
	Mojo::IOLoop->one_tick;

	is( $#results, $position, 'End position is right' );

	my( $first_defined ) = grep { defined $results[$_] } 0 .. $#results;
	is( $first_defined, $position, 'First defined position is right' );
	is(
		ref $results[$position],
		ref [],
		'First defined position is an array ref'
		);

	is_deeply $results[$position], [ qw(Bender Leela) ], 'Result is correct';
	is_deeply \@errors, [], 'promise not rejected';
	}

subtest first  => sub { resolve_one( 20,  0 ) };
subtest last   => sub { resolve_one( 20, 19 ) };
subtest random => sub { resolve_one( 20, int rand 20 ) };

subtest none => sub {
	my @promises = map {
		Mojo::Promise->new
		} 0 .. 5;

	my $first = Mojo::Promise
		->with_roles('+Any')
		->any( @promises );
	isa_ok( $first, $target );

	my( @results, @errors );
	$first->then(
		sub { @results = @_ },
		sub { @errors  = @_ }
		);

	$_->reject foreach @promises;
	Mojo::IOLoop->one_tick;

	is( $#results, -1, 'End position is right' );

	my( $first_defined ) = grep { defined $results[$_] } 0 .. $#results;
	is( $first_defined, undef, 'There is no first position' );

	is( scalar @results, 0 );
	is( scalar @errors,  0 );
	};

subtest all => sub {
	my @promises = map {
		Mojo::Promise->new
		} 0 .. 5;

	my $first = Mojo::Promise
		->with_roles('+Any')
		->any( @promises );
	isa_ok( $first, $target );

	my( @results, @errors );
	$first->then(
		sub { @results = @_ },
		sub { @errors  = @_ }
		);

	$promises[$_]->resolve($_) foreach 0 .. $#promises;
	Mojo::IOLoop->one_tick;

	is( scalar @results, 1 );
	is( scalar @errors,  0 );
	};

subtest no_promises => sub {
	my $first = Mojo::Promise
		->with_roles('+Any')
		->any();
	isa_ok( $first, $target );

	my $failed;
	$first->then( undef, sub { $failed = 'Good' } );
	is( $failed, 'Good' );
	};

done_testing();
