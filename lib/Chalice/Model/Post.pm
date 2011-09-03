package Chalice::Model::Post;
use strict;
use warnings;

sub title               { $_[0]->{title}             }
sub url                 { $_[0]->{url}               }
sub body_source         { $_[0]->{body_source}       }
sub body_format         { $_[0]->{body_format}       }
sub creation_date       { $_[0]->{creation_date}     }
sub modification_date   { $_[0]->{modification_date} }
sub model               { $_[0]->{model}             }

1;
