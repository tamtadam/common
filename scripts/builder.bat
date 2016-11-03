call perl f:\GIT\common\scripts\remove_trailing_lines.pl %*
call f:\GIT\common\scripts\dos2unix.exe %*
call perl f:\GIT\common\scripts\copy_from_git2xampp.pl %*

call perl -wc %*