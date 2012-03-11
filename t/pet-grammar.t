#! perl

use strict;
use warnings;

use Test::More;

use PetVM::PetParser;
use IO::Scalar;

# create a new parser
my $parser = PetVM::PetParser->new;

# buffer to hold the parsed syntax
my $buf     = undef;
my $opcodes = undef;

# test PUSH numeric
$buf = << 'EOF';
PUSH 1
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 16, 'Invalid opcode for PUSH detected!');
# test argument
is($opcodes->[0]->[1]->[0], 1, 'Invalid PUSH parameter detected!');

# test PUSH string
$buf = << 'EOF';
PUSH "Hello"
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 16, 'Invalid opcode for PUSH detected!');
# test argument
is($opcodes->[0]->[1]->[0], "Hello", 'Invalid PUSH parameter detected!');

done_testing();
