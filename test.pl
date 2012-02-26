#!perl

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

#print Dumper($pet);
