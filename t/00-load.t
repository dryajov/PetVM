#!perl -T

use Test::More tests => 3;

BEGIN {
    use_ok( 'PetVM' ) || print "Bail out!\n";
    use_ok( 'PetVM::PetLexer' ) || print "Bail out!\n";
    use_ok( 'PetVM::PetParser' ) || print "Bail out!\n";
}

diag( "Testing PetVM $PetVM::VERSION, Perl $], $^X" );
