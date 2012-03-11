package PetVM::PetLexer;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';

use Lexer::Lex;

use strict;

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

    # no arg opcodes
    my $opcodes = qr/ADD|SUBST|DIV|MUL|MOD|SHL|SHR|AND|OR|
                       COMP|XOR|POP|CALL|RET|OUT|IN|STORE|LOAD/xo;

	# jump opcodes need a label
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
        [ 'OP',      qr/$opcodes+/x, ],
        [ 'OP_PUSH', qr/PUSH/x, ],
        [ 'OP_JMP',  qr/$jmp_opcodes/x, ],
        [
           'STRING',
           qr/$string/x,
           sub {
               my $lex     = shift;
               my $content = $lex->last()->content;
               $content =~ s/\"//g; # strip double quotes from the text
               $lex->last()->content($content);
             }
        ],
        [ 'NUMBER', qr/$number/x, ],
        [
           'LABEL',
           qr/\w+:/x,
           sub {
               my $lex     = shift;
               my $content = $lex->last()->content;
               $content =~ s/:$//g; # strip ":" from the end
               $lex->last()->content($content);
             }
        ],
        [
           'LABEL_REF',
           qr/\[\w+\]/x,
           sub {
               my $lex     = shift;
               my $content = $lex->last()->content;
               $content =~ s/\[(.*)\]/$1/g;    # strip [], we don't need that
               $lex->last()->content($content);
             }
        ],
        [ 'IGNORE',   qr/$ignored/x,  undef, 1 ],
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

# Return next token if next 
# token is EOF then we return 
# an empty string and an undef to
# signal EOF to YAPP
sub token {
    my $self = shift;

    my $token = $self->lexer->token;
    my ( $label, $content ) = ( $token->label, $token->content );

    if ( $label eq 'EOF' ) {
        ( $label, $content ) = ( '', undef );
    } elsif ( $label eq 'NEWLINE' ) {
        ($label) = '';
    }

    return ( $label, $content );
}

# simple wrapper for Lexer::Lex from method
sub from {
    my ( $self, $file ) = @_;
    $self->lexer->from($file);
    return;
}

1;

__END__

=head1 NAME

B<PetVM> lexer definition.

=head1 SYNOPSIS

 use PetVM::PetLexer;

 my $lexer = PetVM::PetLexer->new;
 $lexer->from( IO::Scalar->new( \$buf ) );
 my ($label, $conent) = $lexer->token;

=head1 DESCRIPTION

This is the B<Lexer::Lex> based parser module for B<PetVM>. It is capable of tokenizing a B<PetVM> assembly definition.

=head1 METHODS

=head2 new

my $parser = PetVM::PetParser->new;

The C<new> method creates a new B<PetVM::PetLexer> object.

=head2 from( $file_handle )

$lexer->from( IO::Scalar->new( \$buf ) );

The C<parse> method parses B<PetVM> assembly code. It expects a valid file handle as a parameter.

=head2 toke

$lexer->token;

The C<token> returns the current token. When called it will return a list of two elements, a label and the content of the token. If the end of the input is reached, then an empty label and an undef content will be returned. This is used by B<Parse::Yapp> derived B<PetVM::PetParser> to identify an EOF.

=head1 AUTHOR

Dmitriy Ryajov, <dryajov@gmail.com> 

=cut
