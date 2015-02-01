package PetVM;

use 5.010;
use strict;
use warnings;

use Moose;
use Modern::Perl;
use TryCatch;
use IO::Handle;
use Carp;
use Data::Dumper;
use Scalar::Util;

our $VERSION = '0.01';

use Exporter;
use base qw/Exporter/;

our @EXPORT_OK;
our %EXPORT_TAGS;

# setup the instructions hash so that it can be
# imported from parsers and such
BEGIN {

	our %opcodes;    # holds a map of opcode name to opcode id

	# exported by default, all parsers should
	# use this to create the executable
	@EXPORT_OK = qw(%opcodes);

	%EXPORT_TAGS = (
		OPCODES => [
			qw(OP_ADD
			  OP_SUBST
			  OP_DIV
			  OP_MUL
			  OP_MOD
			  OP_SHL
			  OP_SHR
			  OP_AND
			  OP_OR
			  OP_COMP
			  OP_XOR
			  OP_JMP
			  OP_JMPEQ
			  OP_JMPNEQ
			  OP_JMPGT
			  OP_JMPLT
			  OP_PUSH
			  OP_POP
			  OP_CALL
			  OP_RET
			  OP_OUT
			  OP_IN
			  OP_STORE
			  OP_LOAD
			  OP_CLS )
		],
	);

	# export the opcodes
	map { push @EXPORT_OK, $_; } @{ $EXPORT_TAGS{OPCODES} };

	{

		# this is silly but necesary
		# we need this to create sub
		# based constants
		no strict 'refs';
		no strict 'subs';

		# I whish perl had real enums...
		my $const_cnt = 0;
		map {
			*{$_} = sub { $const_cnt++ };    # create constants using subs
			$opcodes{$_} = &{$_};            # map into the opcode hash
		} @{ $EXPORT_TAGS{OPCODES} };
	}
}

# array of instructions
# each entry contains a reference to another array
# in the form of [[OP, [p1, p2, ... pN]]]
#
# where OP is the opcode code and the array ref is an
# (optional) array of parameters passed to the instruction
has 'instructions' => (
	isa      => 'ArrayRef[ArrayRef]',
	is       => 'rw',
	required => 1
);

# current instruction pointer
# (offset into instructions)
has 'ip' => (
	isa      => 'Num',
	is       => 'rw',
	default  => 0,
	init_arg => undef,
);

# the execution stack
has 'stack' => (
	isa      => 'ArrayRef',
	is       => 'rw',
	default  => sub { [] },
	init_arg => undef,
);

# speciall stack used for subrutine
# call return addresses
has 'address_stack' => (
	isa      => 'ArrayRef',
	is       => 'rw',
	default  => sub { [] },
	init_arg => undef
);

# a pseudo heap
has 'heap' => (
	isa      => 'ArrayRef[ArrayRef]',
	is       => 'rw',
	builder  => '_init_heap',
	init_arg => undef,
);

# build the heap - 256 possible memory locations
sub _init_heap {
	my @heap;

	# construct a heap of 256 elements
	for ( 0 .. 255 ) {
		push @heap, [
					  0,        # the used free bit
					  undef,    # the actual value
		];
	}

	return \@heap;
}

# a map of OP codes to internal subrutines
has 'routines' => (
					isa      => 'ArrayRef[CodeRef]',
					is       => 'ro',
					builder  => '_build_routines',
					init_arg => undef,
);

# build the rutines
sub _build_routines {
	return [
			 \&ADD,   \&SUBST, \&DIV,   \&MUL,    \&MOD,
			 \&SHL,   \&SHR,   \&AND,   \&OR,     \&COMP,
			 \&XOR,   \&JMP,   \&JMPEQ, \&JMPNEQ, \&JMPGT,
			 \&JMPLT, \&PUSH,  \&POP,   \&CALL,   \&RET,
			 \&OUT,   \&IN,    \&STORE, \&LOAD,   \&CLS,
	];
}

sub move_next {
	my $self = shift;

	#  return an instruction and increment
	my $ip = $self->instructions->[ $self->ip ];
	$self->ip( $self->ip + 1 );
	return $ip;
}

sub run {
	my $self = shift;

	while ( my $OP = $self->move_next ) {
		$self->op_eval($OP);
	}

	return;
}

sub op_eval {
	my $self = shift;
	my $OP   = shift;

	my $routine = $self->routines->[ $OP->[0] ];
	my $res = $routine->( $self, $OP->[1] );

	return $res;
}

sub _find_free_block {
	my $self = shift;
	my $size = shift;        # size if the block of address to search for
	my $addr = shift || 0;

	my $curr_size = 0;
	foreach my $index ( $addr .. @{ $self->heap } ) {
		if ( $self->heap->[$index]->[0] == 1 ) {
			return $self->_find_free_block( $size, ++$index );
		}
	} continue {
		$index++;
		last
		  if ( ++$curr_size >= $size );
	}

	return ( $addr, $curr_size );
}

sub _peek {
	my $self = shift;

	return $self->stack->[-1];
}

sub _dump_stack {
	my $self = shift;

	my $stack = $self->stack;

	print "DUMPING STACK: ", Dumper($stack), "\n";

	return;
}

sub _trace {
	my $self = shift;
	my $msg  = shift;

	# print a trace message
	carp $msg;

	# dump the stack
	$self->_dump_stack();

	croak "General error, bailing out!!!";
}

sub _is_numeric_pair {
	my $self = shift;

	my ( $a, $b ) = @_;

	return (    Scalar::Util::looks_like_number($a)
			 && Scalar::Util::looks_like_number($b) );
}

# IMPLEMENT THE OPCODE ROUTINES

# STACK MANIPULATION

# pushes an element onto the stack
sub PUSH {
	my $self = shift;
	my $arg  = shift;

	push @{ $self->stack }, ref $arg ? $arg->[0] : $arg;

	#print Dumper( \@{ $self->stack } );
	return;
}

# pops an element from the stack
sub POP {
	my $self = shift;

	my $val = pop @{ $self->stack };

	#print Dumper( \@{ $self->stack } );

	return $val;
}

# ARITHMETIC

# adds two numbers
#
# the numbers are poped from the stack
# and the answer is pushed onto the stack
sub ADD {
	my $self = shift;

	my $b = $self->POP;
	my $a = $self->POP;

	$self->PUSH( $a + $b );

	return;
}

# substracts two numbers
#
# the numbers are poped from the stack
# and the answer is pushed onto the stack
sub SUBST {
	my $self = shift;

	my $b = $self->POP;
	my $a = $self->POP;

	$self->PUSH( $a - $b );

	return;
}

# multiplies two numbers
#
# the numbers are poped from the stack
# and the answer is pushed onto the stack
sub MUL {
	my $self = shift;

	my $b = $self->POP;
	my $a = $self->POP;

	$self->PUSH( $a * $b );

	return;
}

# divides two numbers
#
# the numbers are poped from the stack
# and the answer is pushed onto the stack
sub DIV {
	my $self = shift;

	my $b = $self->POP;
	my $a = $self->POP;

	$self->PUSH( $a / $b );

	return;
}

# gets the modulus of two numbers
#
# the numbers are poped from the stack
# and the answer is pushed onto the stack
sub MOD {
	my $self = shift;

	my $b = $self->POP;
	my $a = $self->POP;

	$self->PUSH( $a % $b );

	return;
}

# BITWISE

# shift the a number left N number of possitions
#
# the numbers are poped from the stack
# and the answer is pushed onto the stack
sub SHL {
	my $self = shift;

	my $b = $self->POP;
	my $a = $self->POP;

	$self->PUSH( $a << $b );

	return;
}

# shift the a number right N number of possitions
#
# the numbers are poped from the stack
# and the answer is pushed onto the stack
sub SHR {
	my $self = shift;

	my $b = $self->POP;
	my $a = $self->POP;

	$self->PUSH( $a >> $b );

	return;
}

# ANDs two numbers
#
# the numbers are poped from the stack
# and the answer is pushed onto the stack
sub AND {
	my $self = shift;

	my $b = $self->POP;
	my $a = $self->POP;

	$self->PUSH( $a & $b );

	return;
}

# ORs two numbers
#
# the numbers are poped from the stack
# and the answer is pushed onto the stack
sub OR {
	my $self = shift;

	my $b = $self->POP;
	my $a = $self->POP;

	$self->PUSH( $a | $b );

	return;
}

# XORs two numbers
#
# the numbers are poped from the stack
# and the answer is pushed onto the stack
sub XOR {
	my $self = shift;

	my $b = $self->POP;
	my $a = $self->POP;

	$self->PUSH( $a ^ $b );

	return;
}

# complement of a number
#
# the numbers are poped from the stack
# and the answer is pushed onto the stack
sub COMP {
	my $self = shift;

	my $a = $self->POP;

	$self->PUSH( ~$a );

	return;
}

# BRANCHING
sub JMP {
	my $self = shift;

	# get the instruction to jump to
	return $self->ip( $self->POP );
}

sub JMPEQ {
	my $self = shift;

	my $jmp = $self->POP;    # pop the jump location

	my $b = $self->POP;
	my $a = $self->POP;

	my $res;
	if ( $self->_is_numeric_pair( $a, $b ) ) {
		$res = $a == $b;
	} else {
		$res = $a eq $b;
	}

	if ($res) {
		$self->PUSH($jmp);
		$self->JMP;
	}

	return;
}

sub JMPNEQ {
	my $self = shift;

	my $jmp = $self->POP;    # pop the jump location

	my $b = $self->POP;
	my $a = $self->POP;

	my $res;
	if ( $self->_is_numeric_pair( $a, $b ) ) {
		$res = $a != $b;
	} else {
		$res = $a ne $b;
	}

	if ($res) {
		$self->PUSH($jmp);
		$self->JMP;
	}

	return;
}

sub JMPLT {
	my $self = shift;

	my $jmp = $self->POP;    # pop the jump location

	my $b = $self->POP;
	my $a = $self->POP;

	my $res;
	if ( $self->_is_numeric_pair( $a, $b ) ) {
		$res = $a < $b;
	} else {
		$res = $a lt $b;
	}

	if ( $a < $b ) {
		$self->PUSH($jmp);
		$self->JMP;
	}

	return;
}

sub JMPGT {
	my $self = shift;

	my $jmp = $self->POP;    # pop the jump location

	my $b = $self->POP;
	my $a = $self->POP;

	my $res;
	if ( $self->_is_numeric_pair( $a, $b ) ) {
		$res = $a > $b;
	} else {
		$res = $a gt $b;
	}

	if ($res) {
		$self->PUSH($jmp);
		$self->JMP;
	}

	return;
}

# SUBRUTINE CALLS

sub CALL {
	my $self = shift;

	push @{ $self->address_stack },
	  $self->ip;    # push the return location onto the call stack

	$self->JMP;     # jump to the call

	return;
}

sub RET {
	my $self = shift;

	$self->PUSH( pop @{ $self->address_stack } )
	  ;             # pop the return location from the call stack
	$self->JMP;     # return to calle

	return;
}

# PSEUDO I/O HANDLERS

sub OUT {
	my $self = shift;

	my $data = $self->POP;    # pop the data into an internal register

	#print the text
	if ( !defined fileno($data) ) {
		if ( ref $data =~ /SCALAR/ ) {
			print $$data;
		} elsif ( ref $data !~ /SCALAR/ ) {
			$self->_trace("Operation not suported!\n");
		} else {
			print $data;
		}
	} else {

		# print the file handle out line by line
		while (<$data>) {
			print;
		}
	}

	return;
}

sub IN {
	my $self = shift;

	my ( $addr, $size ) = $self->_find_free_block(1);

	my $fh   = $self->POP;    # pop the filehandle
	my $data = <$fh>;         # read the data in

	$self->PUSH($data);       #push the data onto the heap
	$self->PUSH($addr);
	$self->STORE;
	$self->PUSH($addr);       #push the address again so that

	return;
}

# HEAP HANDLERS

sub LOAD {
	my $self = shift;

	my $addr = $self->POP;

	$self->PUSH( $self->heap->[$addr]->[1] );

	return;
}

sub STORE {
	my $self = shift;

	my $addr = $self->POP;
	my $val  = $self->_peek;    # don't remove from stack

	$self->_trace("Address out of bounds!") if $addr > 255;

	$self->heap->[$addr]->[0] = 1;
	$self->heap->[$addr]->[1] = $val;

	return;
}

# clears an anddress
sub CLS {
	my $self = shift;

	my $addr = $self->POP;

	$self->heap->[$addr]->[0] = 0;
	$self->heap->[$addr]->[1] = undef;

	return;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

PetVM - Perl experimental and toy VM

=head1 SYNOPSIS

 use strict;
 use warnings;

 use PetVM::PetParser;
 use IO::Scalar;
 use Data::Dumper;

 # buffer to hold the parsed syntax
 my $buf;

 # test PUSH numeric
 $buf = << 'EOF';

 // init counter
 PUSH    1000
 PUSH    0
 STORE           // store away the initial counter

 // loop untill 0
 LOOP:
     PUSH    1
     SUBST                               // n - 1
     PUSH    0
     STORE                               // put result in address 0
     PUSH   "\n"
     PUSH    0
     LOAD                                // load value from address 0 on to the stack
     PUSH    "VALUE IS: "                // put string on stack
     OUT
     OUT
     OUT
     PUSH    0
     LOAD                                // load value from address 0 on to the stack
     PUSH    0                           // push value to compare to
 JMPNEQ   [LOOP]

 EOF

 # create a new parser
 my $parser = PetVM::PetParser->new;

 $parser->parse( IO::Scalar->new( \$buf ) );

 my $instructions = $parser->get_opcodes();

 my $pet = PetVM->new( instructions => $instructions );
 $pet->run();

=head1 DESCRIPTION

The aim of PetVM is to create a simple stack based virtual machine,
mostly for demostration purposes.

=head1 OPCODES

 ADD     0
 SUBST   1
 DIV     2
 MUL     3
 MOD     4

 SHL     5
 SHR     6
 AND     7
 OR      8
 COMP    9
 XOR     10

 JMP     11
 JMPEQ   12
 JMPNEQ  13
 JMPGT   14
 JMPLT   15

 PUSH    16
 POP     17

 CALL    18
 RET     19

 OUT     20
 IN      21

 STORE   22
 LOAD    23
 CLS     24

=head1 METHODS

=head2 new

my $pet = PetVM->new( instructions => [...] );

The C<new> constructor lets you create a new B<PetVM> object.

Returns a new B<PetVM> object or dies on error.

=head2 run

$pet->run;

The C<run> method executes a previosly created B<PetVM> object.

=head1 SUPPORT

This module is free software. No warranty of any kind is provided.

=head1 AUTHOR

Dmitriy Ryajov <dryajov@gmail.com>

=cut
