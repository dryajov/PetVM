#! perl

use strict;
use warnings;

use Test::More;

use PetVM::PetParser;
use IO::Scalar;

# create a new parser
my $parser = new PetVM::PetParser;

# buffer to hold the parsed syntax
my $buf;

# test PUSH numeric
$buf = << 'EOF';
PUSH 1
EOF

$parser->run(IO::Scalar->new(\$buf));

done_testing();
