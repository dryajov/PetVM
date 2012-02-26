package PetVM::PetLexer;

use 5.006;
use strict;
use warnings;

=head1 NAME

PetVM::PetLexer - The great new PetVM::PetLexer!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Lexer::Lex;

use strict;

sub _print {
	my $lex = shift;
	print "LABEL: ", $lex->last()->label, " - ";
	print $lex->last()->content, "\n";

	return;
}

sub new {
	my $class = shift;
	my $self  = {};

	bless $self, $class;

	my $lex = $self->init_lexer();
	$self->{lexer} = $lex;

	return $self;
}

sub lexer {
	my $self = shift;

	return $self->{lexer};
}

sub init_lexer {

	# OPCODES
	my $opcodes =  qr/ADD|SUBST|DIV|MUL|MOD|SHL|SHR|AND|OR|
	                   COMP|XOR|POP|CALL|RET|OUT|IN|STORE|LOAD/xo;
	                   
    my $jmp_opcodes = qr/JMPEQ|JMPNEQ|JMPGT|JMPLT|JMP/xo;

	# Match strings
	my $string = qr{
                  ".*"  # match anything within ""
               }xom;

	# Match numbers
	my $number = qr{
                  \d+  # match a number
               }xom;

	# match comments
	my $comments = qr{//*.+}ox;

    # these are ignored
    my $ignored = qr{^[\s|\n]+?}ox;

	my @tokens = (
		[
		  'OP',
		  qr/$opcodes+/x,
		],
        [
          'OP_PUSH',
          qr/PUSH/x,
        ],
        [
          'OP_JMP',
          qr/$jmp_opcodes/x,
        ],
		[
		  'STRING',
		  qr/$string/x,
          sub {
            my $lex = shift;
            my $content = $lex->last()->content;
            $content =~ s/\"//g;
            $lex->last()->content($content);
          } 		  
		],
		[
		  'NUMBER',
		  qr/$number/x,
		],
		[
		  'LABEL',
		  qr/\w+:/x,
          sub {
            my $lex = shift;
            my $content = $lex->last()->content;
            $content =~ s/:$//g;
            $lex->last()->content($content);
          }		  
		],
		[
		  'LABEL_REF',
		  qr/\[\w+\]/x,
		  sub {
		  	my $lex = shift;
		  	my $content = $lex->last()->content;
		  	$content =~ s/\[(.*)\]/$1/g; # strip [], we don't need that
		  	$lex->last()->content($content);
		  }
		],
		[ 'IGNORE', qr/$ignored/x, undef, 1 ],
		[ 'COMMENTS', qr/$comments/x, undef, 1 ],
	);

	my $lexer = Lexer::Lex->new(
		\@tokens,
		sub {
			my $lex = shift;
			my $tok = $lex->{_unmatch};
			print $tok->label,   "\n";
			print $tok->content, "\n";
			die "Unable to parse line, " . $lex->get_line . "!\n";
		},
		"\n"
	);

	return $lexer;
}

sub token {
	my $self = shift;

    my $token = $self->lexer->token;
    my ($label, $content) = ( $token->label, $token->content ); 

    if ($label eq 'EOF') {
    	($label, $content) = ('', undef);
    } elsif ($label eq 'NEWLINE') {
    	($label) = '';
    }

	return ($label, $content);
}

sub from {
	my ( $self, $file ) = @_;
	$self->lexer->from($file);
	return;
}

1;

__END__

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use PetVM::PetLexer;

    my $foo = PetVM::PetLexer->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don' t export anything, such as for a purely object-oriented module .

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

			 sub function1 {
		   }

=head2 function2

=cut

		   sub function2 {
		   }

=head1 AUTHOR

Dmitriy Ryajov, C<< <dryajov at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-petvm at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PetVM>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PetVM::PetLexer


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=PetVM>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/PetVM>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/PetVM>

=item * Search CPAN

L<http://search.cpan.org/dist/PetVM/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Dmitriy Ryajov.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

		   1;    # End of PetVM::PetLexer
