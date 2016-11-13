SET foo=%PATH%
ECHO %foo%

call perl %GIT_ROOT%\common\scripts\remove_trailing_lines.pl %*
call %GIT_ROOT%\common\scripts\dos2unix.exe %*
call perl %GIT_ROOT%\common\scripts\copy_from_git2xampp.pl %*

call perl -wc %*

ECHO %GIT_ROOT%

