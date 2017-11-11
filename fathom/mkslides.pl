use strict;
use warnings qw(all FATAL);
use Text::Markdown::Discount qw(markdown);

binmode STDIN, ':utf8';
binmode STDOUT, ':utf8';

my @classes;
my @content;
my @notes;
my $header_done;

print <<'EOF';
<html>
<head>
<meta name="viewport" content="width=1024" />
<meta charset="UTF-8">
<title></title>
<link href="style.css" rel="stylesheet" type="text/css" />
<link href="fathom.css" rel="stylesheet" type="text/css" />
<script src="jquery.min.js" type="text/javascript"></script>
<script src="fathom.min.js" type="text/javascript"></script>
<script type="text/javascript">
$(document).ready(function(){
	$("#presentation").fathom();
	$(".slide").bind('activateslide.fathom', function(){
		console.log($(this).text());
	});
});
</script>
</head>

<body>
<div id="presentation">
EOF

while(<>) {
	if (/^---$/) {
		emit();
		clear();
	}
	elsif (m{^//\s*(.*)}) {
		push @notes, $1;
	}
	elsif ($header_done) {
		push @content, $_;
	}
	elsif (/^$/) {
		$header_done = 1;
	}
	else {
		push @classes, split;
	}
}
emit();

print <<'EOF';
</body>
</html>
EOF

exit 0;

sub clear {
	@classes = ();
	@content = ();
	@notes = ();
	$header_done = 0;
}

sub emit {
	return unless @content;
	print qq(<div class="slide">\n);
	print qq(<div class="@{[join(' ', @classes)]}">\n) if @classes;
	print markdown(join('', @content));
	print qq(</div>\n) if @classes;
	if (@notes) {
		print qq(<div class="notes">\n);
		print markdown(join("\n", @notes));
		print qq(</div>\n);
	}
	print qq(</div>\n);
}
