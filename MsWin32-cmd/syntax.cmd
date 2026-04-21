
rem # When the command itself is echoed (as when you CALL a batch file and watch
rem # console output,) an extra space is shown before the closing parenthesis.
rem # However, there will be no trailing space in output.txt
(echo ExitCode=%ErrorLevel%) >> output.txt
rem %ErrorLevel% value is preserved

