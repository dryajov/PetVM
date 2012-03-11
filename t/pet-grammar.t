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
is($opcodes->[0]->[0], 16, 'PUSH detected!');
# test argument
is($opcodes->[0]->[1]->[0], 1, 'PUSH parameter detected!');

# test PUSH string
$buf = << 'EOF';
PUSH "Hello"
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 16, 'PUSH detected!');
# test argument
is($opcodes->[0]->[1]->[0], "Hello", 'PUSH parameter detected!');

# test ADD
$buf = << 'EOF';
ADD
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 0, 'ADD detected!');

# test SUBST
$buf = << 'EOF';
SUBST
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 1, 'SUBST detected!');

# test DIV
$buf = << 'EOF';
DIV
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 2, 'DIV detected!');

# test MUL
$buf = << 'EOF';
MUL
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 3, 'MUL detected!');

# test MOD
$buf = << 'EOF';
MOD
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 4, 'MOD detected!');

# test SHL
$buf = << 'EOF';
SHL
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 5, 'SHL detected!');

# test SHR
$buf = << 'EOF';
SHR
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 6, 'SHR detected!');

# test AND
$buf = << 'EOF';
AND
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 7, 'AND detected!');

# test OR
$buf = << 'EOF';
OR
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 8, 'OR detected!');

# test COMP
$buf = << 'EOF';
COMP
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 9, 'COMP detected!');

# test XOR
$buf = << 'EOF';
XOR
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 10, 'XOR detected!');

# test JMP
$buf = << 'EOF';
LABEL:
JMP [LABEL]
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[0]->[1]->[0], 0, 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[1]->[0], 11, 'JMP detected!');

# test JMPEQ
$buf = << 'EOF';
PUSH 1
PUSH 1
LABEL:
JMPEQ [LABEL]
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[0]->[1]->[0], 1, 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[1]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[1]->[1]->[0], 1, 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[2]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[2]->[1]->[0], 2, 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[3]->[0], 12, 'JMPEQ detected!');

# test JMPNEQ
$buf = << 'EOF';
PUSH 1
PUSH 1
LABEL:
JMPNEQ [LABEL]
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[0]->[1]->[0], 1, 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[1]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[1]->[1]->[0], 1, 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[2]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[2]->[1]->[0], 2, 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[3]->[0], 13, 'JMPNEQ detected!');

# test JMPNGT
$buf = << 'EOF';
PUSH 1
PUSH 1
LABEL:
JMPGT [LABEL]
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[0]->[1]->[0], 1, 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[1]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[1]->[1]->[0], 1, 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[2]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[2]->[1]->[0], 2, 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[3]->[0], 14, 'JMPGT detected!');

# test JMPNLT
$buf = << 'EOF';
PUSH 1
PUSH 1
LABEL:
JMPLT [LABEL]
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[0]->[1]->[0], 1, 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[1]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[1]->[1]->[0], 1, 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[2]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[2]->[1]->[0], 2, 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[3]->[0], 15, 'JMPLT detected!');

# test OUT
$buf = << 'EOF';
PUSH "Hello"
OUT
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[0]->[1]->[0], "Hello", 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[1]->[0], 20, 'OUT detected!');

# test IN
$buf = << 'EOF';
PUSH "*STDIN"
IN
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[0]->[1]->[0], "*STDIN", 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[1]->[0], 21, 'IN detected!');

# test STORE
$buf = << 'EOF';
PUSH 1
PUSH 1
STORE
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[0]->[1]->[0], 1, 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[1]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[1]->[1]->[0], 1, 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[2]->[0], 22, 'STORE detected!');

# test LOAD
$buf = << 'EOF';
PUSH 1
PUSH 1
LOAD
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[0]->[1]->[0], 1, 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[1]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[1]->[1]->[0], 1, 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[2]->[0], 23, 'LOAD detected!');

# test CLS
$buf = << 'EOF';
PUSH 1
PUSH 1
CLS
EOF

$parser->parse(IO::Scalar->new(\$buf));
$opcodes = $parser->get_opcodes();

# test for valid opcode
is($opcodes->[0]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[0]->[1]->[0], 1, 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[1]->[0], 16, 'PUSH detected!');

# test for valid argument
is($opcodes->[1]->[1]->[0], 1, 'PUSH parameter detected!');

# test for valid opcode
is($opcodes->[2]->[0], 24, 'CLS detected!');
#use Data::Dumper;
#
#print Dumper($opcodes);

done_testing();
