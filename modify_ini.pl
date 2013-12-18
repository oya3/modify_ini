#<!-- -*- encoding: utf-8n -*- -->
use strict;
use warnings;
use utf8;

use Cwd;
use Encode;
use Encode::JP;

use open IN   => ":encoding(cp932)"; # 入力ファイルはcp932
use open OUT  => ":encoding(cp932)"; # 出力ファイルはcp932
binmode STDIN, ':encoding(cp932)'; # 標準入力はcp932
binmode STDOUT, ':encoding(cp932)'; # 標準出力はcp932
binmode STDERR, ':encoding(cp932)'; #エラー出力はcp932
#binmode STDOUT => ":utf8";

my $_TOP_SECTION_ = '@_NONE_@';
my %gOptions = ();
$gOptions{'section'} = $_TOP_SECTION_;
my $argv = getOptions(\@ARGV, \%gOptions);

print "modify_ini ver. 0.13.12.17.\n";
if( scalar(@{$argv}) != 3 ){
	print "Usage: modify_ini.pl [options] <target file> <key> <value>\n";
	print "  options : -section <name> : section name. defualt is global.\n";
    exit;
}

# ARGVは文字コードを変更してやらないとダメっぽい。
my $file = $argv->[0];
my $key = $argv->[1];
my $value = $argv->[2];
print "file    : [$file]\n";
print "section : [$gOptions{'section'}]\n";
print "key     : [$key]\n";
print "value   : [$value]\n";

my $file_sjis = encode('cp932', $file);
open (IN, "<$file_sjis") or die ("\[$file\]$!");
my @inArray = <IN> ;
close IN;

my @outArray = ();
my $nowSection = $_TOP_SECTION_;
my $flg = 0; # 項目
my $sflg = 0; # セクション
foreach my $line(@inArray){
#	print "before:$line";
	if( $line =~ /^\s*\;/ ){ # コメント
	}
	elsif( $line =~ /^\s*\n$/ ){ # 空行
	}
	elsif( $line =~ /^\s*\[(.+?)\]/ ){ # セクション
		$nowSection = $1;
		if( $gOptions{'section'} eq $nowSection ){
			$sflg = scalar(@outArray); # 指定セクション位置を保持
		}
	}
	elsif( $line =~ /^$key\=(.+?)$/ ){
		if( $gOptions{'section'} eq $nowSection ){
			$line = "$key\=$value\n"; # 指定項目を変更した位置を保持（書き換えたかフラグ）
			$flg = scalar(@outArray);
		}
	}
#	print "after :$line";
	push @outArray, $line;
}

if( 0 == $flg ){ # 指定項目が未登録であるか
	if( 0 != $sflg ){ # セッションは発見済み
		# 見つけたセクションに追加
		splice(@outArray, $sflg+1, 0, "$key\=$value\n");
	}
	else{ # セッションは発見できず
		# セクションごと追加
		push @outArray, "[$gOptions{'section'}]\n";
		push @outArray, "$key=$value\n";
	}
}
# 出力
open (OUT, ">$file_sjis") or die ("\[$file\]$!");
foreach my $line (@outArray){
	print OUT $line;
}
close OUT;


print "complete\n";
exit;

sub getOptions
{
	my ($argv,$options) = @_;
	my @newAragv = ();
	for(my $i=0; $i< @{$argv}; $i++){
		my $key = decode('cp932', $argv->[$i]);
		if( $key =~ /^-(section)$/ ){
			$options->{$1} = decode('cp932', $argv->[$i+1]);
			$i++;
		}
		elsif( $key =~ /^-/ ){
			die "illigal parameter with options ($key)";
		}
		else{
			push @newAragv, $key;
		}
	}
	return (\@newAragv);
}

