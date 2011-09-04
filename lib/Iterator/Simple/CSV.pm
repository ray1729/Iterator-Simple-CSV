package Iterator::Simple::CSV;

use strict;
use warnings FATAL => 'all';

use Sub::Exporter -setup => {
    exports => [ 'icsv' ]
};

use Smart::Comments;

use Text::CSV_XS;
use IO::Handle;
use IO::File;
use Iterator::Simple qw( iterator );
use Carp qw( croak );

sub icsv {
    my $input = shift;
    my $opts = @_ == 1 ? shift @_ : +{ @_ };

    my $use_header   = delete $opts->{use_header};
    my $skip_header  = delete $opts->{skip_header};
    my $column_names = delete $opts->{column_names};    
    
    my $io;
    if ( ref( $input ) ) {
        $io = $input;
    }
    elsif ( $input eq '-' ) {
        $io = IO::Handle->new->fdopen( fileno(STDIN), 'r' );
    }   
    else {
        $io = IO::File->new( $input, O_RDONLY )
            or croak "Open $input: $!";
    }
    
    my $csv = Text::CSV_XS->new( $opts );

    my $fetch_row_method = 'getline';
    
    if ( $skip_header ) {
        $io->getline;
    }
    elsif ( $use_header ) {
        $column_names = $csv->getline( $io );
    }

    if ( $column_names ) {                
        $csv->column_names( $column_names );
        $fetch_row_method = 'getline_hr';
    }

    return iterator {
        return if $io->eof;
        $csv->$fetch_row_method( $io )
            or croak "CSV parse error: " . $csv->error_diag;
    };
}

1;

__END__

