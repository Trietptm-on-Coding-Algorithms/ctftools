def die(msg, exit_code = 1)
  $stderr.puts(msg)
  exit(exit_code)
end

if(ARGV.length != 1)
  puts("Usage: test_shellcode.rb <shellcode.asm>")
  exit(1)
end

# First, compile the shellcode
system("nasm -o tmp_shell #{ARGV[0]}") || die("Couldn't assemble the shellcode")

# Read the file
code = nil
File.open("tmp_shell", "rb") do |f|
  code = f.read()
end

# Clean up by deleting the new file
system("rm tmp_shell")
die("Couldn't read the shellcode from 'shell'") if(code.nil?)

# Convert it to a string
code_str = ""
code.each_byte do |b|
  code_str += ('\x%02x' % b)
end

# Write out the .c file
File.open("tmp_shell.c", "w") do |f|
  f.write(<<EOF
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/mman.h>

char shellcode[] = "#{code_str}";

int main(){
  void * a = mmap(0, 4096, PROT_EXEC |PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_SHARED, -1, 0);
  printf("allocated executable memory at: %p\\n", a);
  ((void (*)(void)) memcpy(a, shellcode, sizeof(shellcode)))();
}
EOF
            )
end

# Compile it
system("gcc -o tmp_shell ./tmp_shell.c") || die("Couldn't compile tmp_shell.c")

# Delete the .c
system("rm ./tmp_shell.c")

# Run it
system("./tmp_shell")

# Delete it
system("rm ./tmp_shell")

